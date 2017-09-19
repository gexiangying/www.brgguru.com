package.path = package.path .. ";./lualib/?.lua"
package.cpath = "?53.dll;?.dll;" .. package.cpath
local luaext = require("luaext")
local crypto = require "crypto"
local mime = require "mime"
local digest = crypto.digest
local d = digest.new("sha1")
local agent = {}
local max_agents = 10
for i=1,max_agents do
	agent[i] = mq.new("service/ws.lua","ws:" .. i)
end

local index = 1
local cts = {}

local function webcrypt(s)
	d:reset()
	local s1 = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
	local s2 = d:final(s .. s1)
	local str = string.gsub(s2,"(%x%x)",function(byte) 
		local n = tonumber("0x" .. byte)
		return string.char(n)
	end)
	return ((mime.b64(str)))
end

local function challenge_response(key, protocol)
    protocol = protocol or ""
    if protocol ~= "" then
        protocol = protocol .. "\r\n"
    end

    local accept = webcrypt(key)
    return string.format("HTTP/1.1 101 Switching Protocols\r\n" ..
                        "Upgrade: websocket\r\n" ..
                        "Connection: Upgrade\r\n" ..
                        "Sec-WebSocket-Accept: %s\r\n" ..
                        "%s\r\n", accept, protocol)
end

local function accept_connection(header)
    -- Upgrade header should be present and should be equal to WebSocket
    if not header["upgrade"] or header["upgrade"]:lower() ~= "websocket" then
        return 400, "Can \"Upgrade\" only to \"WebSocket\"."
    end

    -- Connection header should be upgrade. Some proxy servers/load balancers
    -- might mess with it.
    if not header["connection"] or not header["connection"]:lower():find("upgrade", 1,true) then
        return 400, "\"Connection\" must be \"Upgrade\"."
    end

    -- Handle WebSocket Origin naming convention differences
    -- The difference between version 8 and 13 is that in 8 the
    -- client sends a "Sec-Websocket-Origin" header and in 13 it's
    -- simply "Origin".
    -- local origin = header["origin"] or header["sec-websocket-origin"]
    --if origin and check_origin and not check_origin_ok(origin, header["host"]) then
    --   return 403, "Cross origin websockets not allowed"
    -- end

    if not header["sec-websocket-version"] or header["sec-websocket-version"] ~= "13" then
        return 400, "HTTP/1.1 Upgrade Required\r\nSec-WebSocket-Version: 13\r\n\r\n"
    end

    local key = header["sec-websocket-key"]
    if not key then
        return 400, "\"Sec-WebSocket-Key\" must not be  nil."
    end

    local protocol = header["sec-websocket-protocol"] 
    if protocol then
        local i = protocol:find(",", 1, true)
        protocol = "Sec-WebSocket-Protocol: " .. protocol:sub(1, i and i-1)
    end

    return nil, challenge_response(key, protocol)

end


function ghub.services.accept(content)
	link_iocp(content,ghub.get_self())
	post_recv(content,luaext.guid())
end

function ghub.services.link(content,str)
	cts[content] = true
end

function ghub.services.quit(content)
	if cts[content] then
		remote_content(content)
		cts[content] = nil
	end
end

local function decode(s,cgi)
	for name,value in string.gmatch(s,"([^&=]+)=([^&=]+)") do
		local name = unescape(name)
		local value = unescape(value)
		cgi[name] = value
	end
end

local function fasefile(s,cgi)
	--local path,name,ext = string.match(s,"(.*)/([^%.]+)%.(.*)")
	local path,name,ext = string.match(s,"(.*)/(.*)%.(.*)")
	if path and name and ext then
		cgi.path = path 
		cgi.filename = name
		cgi.fileext = ext
	end
end

local function farse_header(str,env)
	local i,j = string.find(str,"\r\n")
	if not i  or not j then
		return 
	end
	local first = string.sub(str,1,i-1)
	local method,target = string.match(first,"([^%s]+)%s+([^%s]+)%s+.*")
	if method and target then
		env.method = method
		env.target = target
	end

	local last  = string.sub(str,j+1,-1)
	string.gsub(last,"([^%c%s:]+):%s+(.-)\r\n",function(k,v)
		k = string.lower(k)
		env[k] = v
	end)

end

function ghub.services.recv(content,str)
	local env ={}
	farse_header(str,env)
	local code,result = accept_connection(env)
	if code then
		hub_send(content,string.format("HTTP/1.1 %d %s\r\n\r\n",code,result))
		local s = get_socket(content)
		close_socket(s)
		return
	else
		hub_send(content,result)
	end
	link_iocp(content,agent[index],env.target)	
	index = index + 1
	if index > max_agents then index = 1 end
	post_recv(content,luaext.guid())
end


