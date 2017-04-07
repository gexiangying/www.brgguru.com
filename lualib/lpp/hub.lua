local url = require("lpp.url")
local skynet = require "skynet"
local lp = require("lpp.lp")
local mime_code = require "lpp.mime_code"
local unescape = url.unescape
local escape = url.escape

local hub = {}

local BOM = string.char(239) .. string.char(187) .. string.char(191)

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


local function handle_nofound()
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
	local header = {}
	header["Content-Type"] = "text/html"
	return 404,contents,header
end

local function default_handler(cgi)
	local contents
	local fh,err = io.open(cgi.path .. cgi.filename .. "." .. cgi.fileext,"rb")
	if fh and mime_code[cgi.fileext] then
		contents = fh:read("*a")
		if contents:sub(1,3) == BOM then contents = contents:sub(4) end
	else
		return handle_nofound()
	end
	if fh then fh:close() end
	local header = {}
	header["Content-Type"] = mime_code[cgi.fileext]
	return 200,contents,header
end

local function lua_script(cgi)
	local statuscode = 200
	local header = {}
	header["Content-Type"] = "text/html"
	local fh = io.open(cgi.path .. cgi.filename .. "." .. cgi.fileext,"rb")
	if fh then
		fh:close()
		lp.include(cgi.path .. cgi.filename .. "." .. cgi.fileext,cgi)
		local contents = table.concat(cgi.rs_t)
		return statuscode,contents,header
	else
		handle_nofound()
	end
end

local function fix_host(env)
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

local function set_default(cgi,host)
  if not host or not default_index[host] 	then
		host = "default"
	end
	if cgi.path then
		cgi.path = default_index[host].path .. cgi.path .. "/"
	else
		cgi.path = default_index[host].path .. "/"
	end
	cgi.filename = cgi.filename or default_index[host].name 
	cgi.fileext = cgi.fileext or default_index[host].ext
end

function hub.lpp(path,query,header,body)
	local cgi = {}
	local rs_t = {}
  cgi.rs_t = rs_t

	cgi.outfunc = function(s)
		rs_t[#rs_t+1] = s
	end

	fix_host(header)
	fasefile(path,cgi)
  set_default(cgi,header.host)
	cgi.host = header.host
	for k,v in pairs(query) do
		cgi[k] = v
	end
	decode(body,cgi)
	cgi._G = _G
	if cgi.path and cgi.filename and cgi.fileext == "lp" then
		return lua_script(cgi)
	else 
		return default_handler(cgi)
	end
end

return hub
