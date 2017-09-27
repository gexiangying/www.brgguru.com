local lfs = require("lfs")

local rs = {}
local count = {}

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

for k,v in pairs(rs) do
	count_usr(k,v)
end

for k,v in pairs(count) do
	print("usr@" .. k .. " days=" .. v)
	for k1,v1 in pairs(rs[k]) do
		print("\t" .. k1)
	end
end


