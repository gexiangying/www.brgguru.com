package.path = package.path .. ";./lualib/?.lua"
local mime_code = require "lpp.mime_code"
luaext = require("luaext")
socket = require("socket")
local lfs = require("lfs")
local url = require("lpp.url")
local unescape = url.unescape
local escape = url.escape


local BOM = string.char(239) .. string.char(187) .. string.char(191)
local lp = require("lpp.lp")

local default_index ={}

default_index["127.0.0.1"] = { ["path"] ="brg",["name"] ="index",["ext"]="lp"}
default_index["localhost"] = { ["path"] ="brg",["name"] ="index",["ext"]="lp"}
default_index["www.brgguru.com"] = default_index["localhost"] 
default_index["default"] = default_index["localhost"] 

local function decode(s,cgi)
	for name,value in string.gmatch(s,"([^&=]+)=([^&=]+)") do
		name = unescape(name)
		value = unescape(value)
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

local function faseinput(str)
	local line
	local temp = str
	local env = {}
	local cgi = {}
	local need_content = false
	local i,j = string.find(str,"\r\n")
	if not i  or not j then
		return env,cgi
	end
	local first = string.sub(str,1,i-1)
	local method,target = string.match(first,"([^%s]+)%s+([^%s]+)%s+.*")
	if method and target then
		env.method = method
		env.target = target
	end

	local last  = string.sub(str,j+1,-1)
	string.gsub(last,"([^%c%s:]+):%s+([^\n]+)",function(k,v)
		k = string.lower(k)
		env[k] = v
	end)

	if env.target then
		local t,s = string.match(env.target,"([^%?]+)%?(.*)")
		if t and s then
			decode(s,cgi)
			fasefile(t,cgi)
		else
			fasefile(env.target,cgi)
		end
	end
	if env.method == "POST" and env["content-length"] then
		local head_str = string.match(temp,"(.-\r\n\r\n).*")
		if head_str and head_str == temp then
			need_content = true
		else
			local s = string.sub(temp,-tonumber(env["content-length"]),-1)
			decode(s,cgi)
		end
	end
	return need_content,env,cgi
end

local function handle_nofound(content,cgi)
	local contents = [[
	<!DOCTYPE html>
	<html>
	<head>
	<title>Not Found</title>
	</head>
	<body>
	<h1>Not Found</h1>
	</body>
	</html>
	]]
	local rs = "HTTP/1.1 404 Not Found\r\n" 
	rs = rs .. "Content-Type: " .. mime_code["htm"] .. "\r\n"
	rs = rs .. "Content-Length: " .. string.len(contents) .. "\r\n\r\n"
	rs = rs .. contents
	hub_send(content,rs)
end

local function default_handler(content,cgi)
	local contents
	local fh,err = io.open(cgi.path .. cgi.filename .. "." .. cgi.fileext,"rb")
	if fh and mime_code[cgi.fileext] then
		contents = fh:read("*a")
		if contents:sub(1,3) == BOM then contents = contents:sub(4) end
	else
		trace_out(err .. "\n")
		return handle_nofound(content,cgi)
	end
	if fh then fh:close() end
	local rs = "HTTP/1.1 200 OK\r\n" 
	rs = rs .. "Content-Type: " .. mime_code[cgi.fileext] .. "\r\n"
	rs = rs .. "Content-Length: " .. string.len(contents) .. "\r\n"
	rs = rs .. "Cache-Control: max-age=86400\r\n"
	rs = rs .. "\r\n"
	hub_send(content,rs)
	hub_send(content,contents)
	contents = nil
end

local function lua_script(content,cgi)
	--cgi.name = "ge"
	--cgi.io = io
	local rs_t = {}
	function cgi.outfunc(s)
		rs_t[#rs_t+1] = s
	end
	local fh = io.open(cgi.path .. cgi.filename .. "." .. cgi.fileext,"rb")
	if fh then
		fh:close()
		--lp.include(cgi.path .. cgi.filename .. "." .. cgi.fileext,cgi)
		lp.include(cgi.path .. cgi.filename .. "." .. cgi.fileext,cgi)
		local contents = table.concat(rs_t)
		local rs = "HTTP/1.1 200 OK\r\n" 
		rs = rs .. "Content-Type: " .. "text/html" .. "\r\n"
		rs = rs .. "Content-Length: " .. string.len(contents) .. "\r\n"
		rs = rs .. "Cache-Control: no-cache\r\n"
		rs = rs .. "\r\n"
		hub_send(content,rs)
		hub_send(content,contents)
	else
		handle_nofound(content,cgi)
	end
end

function fix_host(env)
	if env.host then
		host,port = string.match(env.host,"([%a%d%.]+):([%a%d%.]+)")
		if host and port then
			env.host = host
			env.port = port
		else
			host = string.match(env.host,"([%a%d%.]+)")
			if host then
				env.host = host
			end
		end
	end
end

function set_default(cgi,host)
	if not host or not default_index[host] 	then
		host = "default"
	end
	cgi.host = host
	if cgi.path then
		cgi.path = default_index[host].path .. cgi.path .. "/"
	else
		cgi.path = default_index[host].path .. "/"
	end
	cgi.filename = cgi.filename or default_index[host].name 
	cgi.fileext = cgi.fileext or default_index[host].ext
end

function process_cmd(content,env,cgi)
	fix_host(env)
	set_default(cgi,env.host)
	cgi._G = _G
	if cgi.path and cgi.filename and cgi.fileext == "lp" then
		lua_script(content,cgi)
	else 
		default_handler(content,cgi)
	end
end


local cts = {}
local last = {}

function ghub.services.link(content,str)
	cts[content] = true
end

function ghub.services.quit(content)

	if cts[content] then
		ip,port = hub_addr(content)
		trace_out("client exit @" .. ip .. ":" ..port .. "\n")
		last[content] = nil
		remote_content(content)
		cts[content] = nil
	end
end

function ghub.services.recv(content,str)
	ip,port = hub_addr(content)

	trace_out("------------------------------------------------------------------\n")
	trace_out("recv : " .. str .. "\n")
	trace_out("------------------------------------------------------------------\n")
	if last[content] then
		str = last[content] .. str
		last[content] = nil
	end
	local need_content,env,cgi = faseinput(str)
	if need_content then
		last[content] = str
	else
		process_cmd(content,env,cgi)
	end
end


