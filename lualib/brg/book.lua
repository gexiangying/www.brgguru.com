local modename = ...
local M = {}
_G[modename] = M
package.loaded[modename] = M

local comma = require("brg.comma")
local assert, error = assert, error
local load= load
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local table = table
local trace_out = trace_out
local book_dir = "brg/book/"
local char = string.char
local open = io.open
local BOM = char(239) .. char(187) .. char(191)
local function loadfile(filename,flag,env)
	local fh = open (filename)
	if fh then 
		local src = fh:read("*a")
		fh:close()
		if src:sub(1,3) == BOM then src = src:sub(4) end
		local f, err = load (src, "@" .. filename, flag, env)
		if not f then error (err, 3) end
		return f
	else
		return nil
	end
end

_ENV = M
head = [[
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1"> 
<link rel="stylesheet" href="jquery/jquery.mobile-1.4.5.min.css">
<script src="jquery/jquery-1.11.1.min.js"></script>
<script src="jquery/jquery.mobile-1.4.5.min.js"></script>
]]

header = [[
<div data-role="header" data-position="fixed" data-fullscreen="false" data-tap-toggle="false">
<div data-role="navbar">
<ul>
<li><a href="book_admin.lp" data-icon="arrow-d">创建账本</a></li>
<li><a href="book.lp" data-icon="home">记账</a></li>
<li><a href="book_edit.lp" data-icon="arrow-u">账本管理</a></li>
<li><a href="book_cal.lp" data-icon="arrow-r">报表</a></li>
</ul>
</div>
</div><!-- /头部 -->

]]

footer = [[
<div data-role="footer" data-position="fixed" data-fullscreen="false" data-tap-toggle="false">
<h4>by gexiangying</h4>
</div><!-- /底部 --></div><!-- /页面 -->
]]

function load_book(bookname)
	local t = {}
	t.db = {}
	local func = loadfile(book_dir .. bookname .. ".lua","bt",t)
	if func then func() end
	return t.db
end

function save_book(bookname,t)
	comma.save_io(book_dir .. bookname .. ".lua",t,"db")
end

function auth_input(db,bookname,passwd)
	if not db.passwd and passwd then db.passwd = passwd end
	return db.passwd == passwd 
end

