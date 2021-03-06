local lfs = require("lfs")

local rs = {}
local count = {}
local name = {}

local function load_name()
	local t = {}
	local func = loadfile("brg/db/dalian-user-list.db","bt",t)
	if func then func() end
	name = t.db
end

local function count_usr(k,v)
	for k1,v1 in pairs(v) do
		count[k] = (count[k] or 0 ) + 1
	end
end

local function process_usr(db,str,day)
	str = str .. "_no"
	if db[str] then
		local no = db[str]
		rs[no] = rs[no] or {}
		rs[no][day] = true
	end
end
local function farse_usr(f,day)
	local t = {}	
	local func = loadfile(f,"bt",t)
	if func then
		func()
		local db = t.db or {}
		process_usr(db,"N",day)
		process_usr(db,"E",day)
		process_usr(db,"S",day)
		process_usr(db,"W",day)
	else
		return
	end
end

local function ls(path)
	for file in lfs.dir(path) do
		if file ~="." and file ~= ".." then
			local day,round,desk = string.match(file,"^(dl[^-]*)-(%d+)-(%d+)%.db$")	
			if day and round and desk then
				local f = path .. "/" .. file
				farse_usr(f,day)
			end
		end
	end
end

ls("brg/db")
load_name()

for k,v in pairs(rs) do
	count_usr(k,v)
end

local f = io.open("brg/usr.html","w")
f:write("<head>\n")
--f:write([[ <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" >]])
f:write([[ <meta name="viewport" content="width=device-width,initial-scale=1">]])
f:write("<meta charset=utf-8>\n")
f:write("<title>活动记录</title>\n")
f:write("</head>\n")
f:write("<html>\n")
f:write("<body>\n")
f:write([[<table width="100%" border="2">]])
for k,v in pairs(count) do
	f:write("<tr><td>" .. name[k] .. "</td><td>" .. v .. "</td></tr>\n")
end
f:write("</table>")
for k,v in pairs(count) do
	f:write("<p>usr@" .. name[k] .. " days=" .. v .. "</p>\n")
	f:write("<ul>\n")
	for k1,v1 in pairs(rs[k]) do
		f:write("<li>" .. k1 .. "</li>")
	end
	f:write("</ul>\n")
end
f:write("</body>\n")
f:write("</html>\n")
f:close()
