local modename = ...
local M = {}
_G[modename] = M
package.loaded[modename] = M

--------------------------------
local comma = require("comma")
local luaext = require("luaext")
local url = require("lpp.url")
local loadfile = loadfile
local load = load
local string = string
local tonumber = tonumber
local pairs = pairs
local tostring = tostring
local trace_out = trace_out
local socket = socket
---------------------------------
_ENV = M

addr = "127.0.0.1"
port = 8000

local session_dir = "apcad/session/"
head = [[
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1"> 
<link rel="stylesheet" href="jquery/jquery.mobile-1.4.5.min.css">
<script src="jquery/jquery-1.11.1.min.js"></script>
<script src="jquery/jquery.mobile-1.4.5.min.js"></script>
]]
function header(sessionid)
	local header_str
	if not sessionid then
		header_str = [[
		<div data-role="header" data-position="fixed">
		<div data-role="navbar">
		<ul>
		<li><a href="index.lp" data-icon="home">login</a></li>
		<li><a href="register.lp" data-icon="arrow-u">register</a></li>
		</ul>
		</div>
		</div><!-- /头部 -->
		]]
	else
		header_str = [[
		<div data-role="header" data-position="fixed">
		<div data-role="navbar">
		<ul>
		<li><a href="login.lp?sessionid=]] .. url.escape(sessionid) ..
		[[" data-icon="home">home</a></li>
		<li><a href="register.lp" data-icon="arrow-u">register</a></li>
		</ul>
		</div>
		</div><!-- /头部 -->
		]]
	end
	return header_str
end
pop_header =[[
<div data-role="header" data-postion="fixed">
<h1></h1>
<a href="#main" data-icon="arrow-l" class="ui-btn-left"></a>
</div>
]]

pop_footer = [[
<div data-role="footer" data-position="fixed">
<h4>by gexiangying</h4>
<a href="#main" data-icon="arrow-l" class="ui-btn-left"></a>
</div><!-- /底部 --></div><!-- /页面 -->
]]

footer = [[
<div data-role="footer" data-position="fixed">
<h4>辽ICP备 160001504</h4>
</div><!-- /底部 --></div><!-- /页面 -->
]]

function session_db(id)
	local t = {}
	t.db = {}
	local func = loadfile(session_dir .. id,"bt",t)
	if func then func() end
	t.db[id] = t.db[id] or {}
	return t.db[id]
end
function session_get(id,k)
	local t = {}
	t.db = {}
	local func = loadfile(session_dir .. id,"bt",t)
	if func then func() end
	t.db[id] = t.db[id] or {}
	return t.db[id][k]	
end

function session_save(id,k,v)
	local t = {}
	t.db = {}
	local func = loadfile(session_dir .. id,"bt",t)
	if func then func() end
	t.db[id] = t.db[id] or {}
	t.db[id][k] = v
	comma.save_file(session_dir .. id,t.db,"db")
end

function sessionid()
	return luaext.guid()
end

function recv_str(content)
	local num = tonumber(content:receive())
	local str = content:receive(num)
	return str
end

function farse_recv(content,t)
	local num = tonumber(content:receive())
	local str = content:receive(num)
	local func = load(str ,"rcv","bt",t)
	if func then func() end
end

function send_str(content,str)
	local prefix = string.len(str) .. "\r\n" .. str
	content:send(prefix)
end
