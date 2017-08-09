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
default_index["www.apcad.com"] = { ["path"] = "apcad",["name"] ="index",["ext"]="lp"}
default_index["www.sofbuilder.com"] = { ["path"] = "apcad",["name"] ="index",["ext"]="lp"}
default_index["127.0.0.1"] = { ["path"] ="apcad",["name"] ="index",["ext"]="lp"}
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
	--[[
	for k,v in pairs(cgi) do
		trace_out(k .. ":" .. v .. "\n")
	end
	--]]
	return need_content,env,cgi
end

local function handle_nofound(content,cgi)
	--[[
	local fh = io.open("50x.html")
	local contents = fh:read("*all")
	fh:close()
	--]]
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
	--local rs = "HTTP/1.1 410 Gone\r\n\r\n" 
	--hub_send(content,rs)
	--local s = get_socket(content)
	--close_socket(s)
	trace_out("send 404 error\n")
end

local function default_handler(content,cgi)
	trace_out("default:" .. cgi.path .. cgi.filename .. "." .. cgi.fileext .. "\n")
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
end

local function lua_script(content,cgi)
	--cgi.name = "ge"
	--cgi.io = io
	local rs_t = {}
	function cgi.outfunc(s)
		rs_t[#rs_t+1] = s
	end
	trace_out("*****************************************************************\n")
	trace_out("lua_script:" .. cgi.path .. cgi.filename .. "." .. cgi.fileext .. "\n")
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
		trace_out("cgi.path = " .. cgi.path .. "\n")
		cgi.path = default_index[host].path .. cgi.path .. "/"
	else
		cgi.path = default_index[host].path .. "/"
	end
	cgi.filename = cgi.filename or default_index[host].name 
	cgi.fileext = cgi.fileext or default_index[host].ext
end
function process_cmd(content,env,cgi)

	trace_out("fix_host()\n")
	fix_host(env)
	--fix_path(env,cgi)
	trace_out("set_default()\n")
  set_default(cgi,env.host)
	trace_out("set default() end \n")
	cgi._G = _G
	if cgi.path and cgi.filename and cgi.fileext == "lp" then
		lua_script(content,cgi)
	else 
		default_handler(content,cgi)
	end
end
--[[
function save_data(content,str)
	local ip,port = hub_addr(content)
	local filename = ip .. port
	local fl = io.open(filename,"wb")
	if lfs.lock(fl,"w") then
		fl:write(str)
		lfs.unlock(fl)
	end
	fl:close()
end
function exist_data(content)
	local ip,port = hub_addr(content)
	local filename = ip .. port
	local fl = io.open(filename,"rb")
	if fl then 
		fl:close()
		return true
	else
		return false
	end
end

function remove_data(content)

	local ip,port = hub_addr(content)
	local filename = ip .. port
	os.remove(filename)
end

function get_data(content)
	local str = ""
	local ip,port = hub_addr(content)
	local filename = ip .. port
	local fl = io.open(filename,"rb")
	if lfs.lock(fl,"r") then
		str = fl:read("a")
		lfs.unlock(fl)
	end
	fl:close()
	return str
end
--]]
function do_send(content)
end

function do_accept(content,str)
	ip,port = hub_addr(content)
	trace_out("do_accept()--thread_num = " .. thread_num .. "  " .. ip .. "@" .. port .. "\n")
	--trace_out("str.len = " .. string.len(str) .. "\n")
	--
	
	if string.len(str) > 0 then
		local need_content,env,cgi = faseinput(str)
		if need_content then
			save_last(content,str)
			trace_out("do_accept() save_last end\n")
		else
			process_cmd(content,env,cgi)
			trace_out("do_accept() process_cmd() end\n")
		end
	end
end

function do_recv(content,str)
	ip,port = hub_addr(content)
	trace_out("do_recv()--thread_num = " .. thread_num .. "  " .. ip .. "@" .. port .. "\n")
	trace_out("------------------------------------------------------------------\n")
	trace_out("recv len = " .. string.len(str) .. "\n")
	trace_out("recv : " .. str .. "\n")
	trace_out("------------------------------------------------------------------\n")
  if exist_last(content) then
		trace_out("do_recv() exist_last \n")
		str = get_last(content) .. str
		remove_last(content)
		trace_out("do_recv() exist_last end\n")
	end
	trace_out("do_recv() faseinput \n")
	local need_content,env,cgi = faseinput(str)
	trace_out("do_recv() faseinput end\n")
	if need_content then
		trace_out("do_recv() save_last \n")
		save_last(content,str)
		trace_out("do_recv() save_last end\n")
	else
		trace_out("do_recv() process_cmd() \n")
		process_cmd(content,env,cgi)
		trace_out("do_recv() process_cmd() end\n")
	end
end


