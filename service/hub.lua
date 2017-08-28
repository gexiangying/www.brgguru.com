package.path = package.path .. ";./lualib/?.lua"
package.cpath = "?53.dll;?.dll;" .. package.cpath
local mime_code = require "lpp.mime_code"
luaext = require("luaext")
socket = require("socket")
local lfs = require("lfs")
local url = require("lpp.url")
local unescape = url.unescape
local escape = url.escape
local router = require("http.router")
local cjson = require("cjson")
local post = require("lpp.post")
local config = require("http.config")
json = cjson.new()

local BOM = string.char(239) .. string.char(187) .. string.char(191)
local lp = require("lpp.lp")

local cts = {}
local Last = {}

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

local function split_header_data(str)
	local header,data = string.match(str,"(.-)\r\n\r\n(.*)")
	return header,data
end

local function farse_header(str,env,cgi)
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

	if env.target then
		local t,s = string.match(env.target,"([^%?]+)%?(.*)")
		if t and s then
			decode(s,cgi)
			fasefile(t,cgi)
		else
			fasefile(env.target,cgi)
		end
	end
end
local function get_discard(content)
	Last[content] = Last[content] or {}
	local datas = Last[content].datas or {}
	return function()
		Last[content].dataindex = #datas + 1 
	end
end
local function get_read(content)
	Last[content] = Last[content] or {}
	Last[content].dataindex = 1
	local datas = Last[content].datas or {}
	return function()
		if #datas < Last[content].dataindex then
			return nil 
		end
		local str = datas[Last[content].dataindex]
		Last[content].dataindex = Last[content].dataindex + 1
		return str
	end
end 

local function tmpfile(filename)
	local f,err = io.open(config.upload_dir .. filename,"wb")
	return f,err
end
local function farse_multi_part(env,cgi,content)
	local lread = get_read(content)
	local ldiscard = get_discard(content)
	post.parsedata{
		read = lread,
		discardinput = ldiscard,
		tmp = tmpfile,
		content_type = env["content-type"],
		content_length = env["content-length"],
		maxinput = config.maxinput,
		maxfilesize = config.maxfilesize,
		args = cgi
	}
end

local function farse_form_data(env,cgi,content)
	local data 
	if string.find(env["content-type"],"application/json") then
		data = table.concat(Last[content].datas)
		cgi.jsonData =	json.decode(data) 
	elseif string.find(env["content-type"],"multipart/form-data",1,true) then
		farse_multi_part(env,cgi,content)
	elseif string.find(env["content-type"],"application/x-www-form-urlencoded",1,true) then
		data = table.concat(Last[content].datas)
		decode(data,cgi)
	else
		data = table.concat(Last[content].datas)
		cgi.postdata = data
	end
end

local function farseinput(content,str)
	local env = {}
	local cgi = {}
	local need_content = false

	if not Last[content] or not Last[content].env then
		local header,data = split_header_data(str)
		if not header then return true,env,cgi end

		farse_header(header,env,cgi)
		trace_out("\n" .. header .. "\n\n")
		Last[content] = {}
		Last[content].env = env
		Last[content].cgi = cgi
		Last[content].datas = {} 
		local datas = Last[content].datas 
		Last[content].datalen = 0
		if string.len(data)>0 then
			datas[#datas + 1] = data
			Last[content].datalen = string.len(data)
		end
	else
		env = Last[content].env
		cgi = Last[content].cgi
		local datas = Last[content].datas 
		datas[#datas + 1] = str 
		Last[content].datalen = Last[content].datalen + string.len(str)
		--trace_out("recv form length = " .. Last[content].datalen .. "\n") 
	end

	if env.method == "POST" and env["content-length"] then
		local len = tonumber(env["content-length"])
		if(Last[content].datalen < len) then
			need_content = true
		else
			farse_form_data(env,cgi,content)
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
	local fname = cgi.path .. cgi.filename .. "." .. cgi.fileext
	local fh,err = io.open(fname,"rb")
	local f_size = 0
	local exist = fh and true
	if fh then fh:close() end
	if exist and mime_code[cgi.fileext] then
		--contents = fh:read("*a")
		--if contents:sub(1,3) == BOM then contents = contents:sub(4) end
		f_size = lfs.attributes(fname,"size")
	elseif exist then
		trace_out("need mimecode :" .. fname .. "\n")
	else
		trace_out(err .. "\n")
		return handle_nofound(content,cgi)
	end
	local rs = "HTTP/1.1 200 OK\r\n" 
	rs = rs .. "Content-Type: " .. mime_code[cgi.fileext] .. "\r\n"
	rs = rs .. "Content-Length: " .. f_size .. "\r\n"
	rs = rs .. "Cache-Control: max-age=86400\r\n"
	rs = rs .. "\r\n"
	hub_send(content,rs)
	TransmitFile(content,fname,"","")
	--hub_send(content,contents)
	--contents = nil
end

local function lua_script(content,cgi)
	--cgi.name = "ge"
	--cgi.io = io
	local rs_t = {}
	function cgi.outfunc(s)
		rs_t[#rs_t+1] = s
	end
	cgi.echo = cgi.outfunc
	cgi.json = json
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


function process_cmd(content,env,cgi)
	router.dispatch(cgi,env.host)
	cgi._G = _G
	if cgi.path and cgi.filename and cgi.fileext == "lp" then
		lua_script(content,cgi)
	else 
		default_handler(content,cgi)
	end
end



function ghub.services.link(content,str)
	cts[content] = true
end

function ghub.services.quit(content)
	if cts[content] then
		ip,port = hub_addr(content)
		trace_out("client exit @" .. ip .. ":" ..port .. "\n")
		Last[content] = nil
		remote_content(content)
		cts[content] = nil
	end
end

function ghub.services.recv(content,str)
	local need_content,env,cgi = farseinput(content,str)
	if not need_content then
		process_cmd(content,env,cgi)
		Last[content] = nil
		str = nil
		local memCount = collectgarbage("count")
		if memCount > 30000 then collectgarbage("collect") end
	end
	post_recv(content,luaext.guid())
end


