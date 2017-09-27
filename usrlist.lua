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
			local day,round,desk = string.match(file,"^(dl.*)-(%d+)-(%d+)%.db$")	
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

local f = io.open("usr.txt","w")

for k,v in pairs(count) do
	f:write(name[k] .. "\t\t" .. v .. "\n")
end

for k,v in pairs(count) do
	f:write("usr@" .. name[k] .. " days=" .. v .. "\n")
	for k1,v1 in pairs(rs[k]) do
		f:write("\t" .. k1 .. "\n")
	end
end
f:close()
