local modename = ...
local M = {}
_G[modename] = M
package.loaded[modename] = M

--------------------------------
local comma = require("comma")
local luabridge = require("brg.luabridge")
local math = math
local pairs = pairs
local assert, error = assert, error
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local load = load
local open = io.open
local table = table
local trace_out = trace_out
local os = os
local db_dir = "brg/db/"
---------------------------------
local char = string.char
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
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" >
<meta name="viewport" content="width=device-width, initial-scale=1" > 
<link rel="stylesheet" href="jquery/jquery.mobile-1.4.5.min.css" />
<script src="jquery/jquery-1.11.1.min.js"></script>
<script src="jquery/jquery.mobile-1.4.5.min.js"></script>
]]
--[[
<div data-role="navbar">
<ul>
<li><a href="admin.lp" data-icon="arrow-d">创建比赛</a></li>
<li><a href="brg.lp" data-icon="home">录入计分</a></li>
<li><a href="edit.lp" data-icon="arrow-u">解锁记录</a></li>
<li><a href="score.lp" data-icon="arrow-r">复式计算</a></li>
</ul>
</div>
--]]
header = [[
<div data-role="header" data-position="fixed" data-fullscreen="false" data-tap-toggle="false">
</div><!-- /头部 -->
]]

pop_header =[[
<div data-role="header" data-postion="fixed">
<h1></h1>
<a href="#test_main" data-icon="arrow-l" class="ui-btn-left"></a>
</div>
]]

pop_footer = [[
<div data-role="footer" data-position="fixed">
<h4>辽ICP备160001504</h4>
<a href="#test_main" data-icon="arrow-l" class="ui-btn-left"></a>
</div><!-- /底部 --></div><!-- /页面 -->
]]

footer = [[
<div data-role="footer" data-position="fixed" data-fullscreen="false" data-tap-toggle="false">
<h4>辽ICP备160001504</h4>
<a href="index.lp" data-icon="home" class="ui-btn-left"></a>
</div><!-- /底部 --></div><!-- /页面 -->
]]
adminfooter = [[
<div data-role="footer" data-position="fixed" data-fullscreen="false" data-tap-toggle="false">
<h4>辽ICP备160001504</h4>
<a href="ge.lp" data-icon="home" class="ui-btn-left"></a>
</div><!-- /底部 --></div><!-- /页面 -->
]]

local function get_day_name()
	local dayname = os.date("%Y-%m-%d")
	return db_dir .. dayname .. "-list.db"
end
local function get_user_name()
	return db_dir .. "dalian-user-list.db"
end
local function get_register_name()
	local dayname = os.date("%Y-%m-%d")
	return db_dir .. dayname .. "-register.db"
end
function add_partner(no1,no2)
	local t = {}
	t.db = {}
	local func = loadfile(get_register_name(),"bt",t)
	if func then func() end
	local db = t.db
	db[#db +1] = {no1=tonumber(no1),no2=tonumber(no2)}
	comma.save_io(get_register_name(),db,"db")
end

function load_partner()
	local t = {}
	t.db = {}
	local func = loadfile(get_register_name(),"bt",t)
	if func then func() end
	return t.db
end

function del_partner(index)
	local db = load_partner()
	table.remove(db,tonumber(index))
	comma.save_io(get_register_name(),db,"db")
end


function load_user_list()
	local t = {}
	t.db = {}
	local func = loadfile(get_user_name(),"bt",t)
	if func then func() end
	return t.db
end

function add_user(name)
	local db = load_user_list()
	db[#db+1] = name
	comma.save_io(get_user_name(),db,"db")
end

function load_tour_list()
	local t = {}
	t.db = {}
	local dayname = get_day_name()
	local func = loadfile(dayname,"bt",t)
	if func then func() end
	return t.db
end


function crt_total(tour_no,rounds)
	local db = {}
	db.rounds = tonumber(rounds)
	db.players = {}
	comma.save_io(db_dir .. tour_no .. ".db",db,"db")
end

function add_total(tour_no,name,round,value)
	local t = {}
	local func = loadfile(db_dir .. tour_no .. ".db","bt",t)
	if func then 
		func() 
		t.db = t.db or {}
		t.db.players = t.db.players or {}
		t.db.players[name] = t.db.players[name] or {} 
		if tonumber(value) < 1000 then
			t.db.players[name][tonumber(round)] = tonumber(value)
		else
			t.db.players[name][tonumber(round)] = nil
		end
		comma.save_io(db_dir .. tour_no .. ".db",t.db,"db")
	end
end

function load_total(tour_no)
	local t = {}
	local func = loadfile(db_dir .. tour_no .. ".db","bt",t)
	if func then 
		func() 
		t.db = t.db or {}
		t.db.players = t.db.players or {}
		local rounds = t.db.rounds or 0
		local pls = {}
    for name,v in pairs(t.db.players) do
	   local pl = {}
		 pl.name = name
		 pl.total = 0
		 pl.vp = {}
		 local nums = 0
		 for round,vp in pairs(v) do
			 if round < rounds + 1 then
				 nums = nums +1
			 end
			 pl.vp[round] = vp
			 pl.total = pl.total + vp
		 end
		 if nums > 0 then
			 pl.total = pl.total / nums
			 pl.total = math.floor(pl.total * 100)/100
		 end
		 pls[#pls+1] = pl
		end
		table.sort(pls,function(a,b) return a.total > b.total end)
		return pls,rounds
	end
	return {},0
end
function input_score(tour_no,no,round)
	local pls = get_tour_pls(no)
	local urs = load_user_list()
	local t = {}
	local func = loadfile(db_dir .. tour_no .. ".db","bt",t)
	if func then 
		func() 
		t.db = t.db or {}
		t.db.players = t.db.players or {}
		for i,v in ipairs(pls) do	
			local name = urs[v.no]
			t.db.players[name] = t.db.players[name] or {} 
			t.db.players[name][tonumber(round)] = tonumber(v.vp)
		end
		comma.save_io(db_dir .. tour_no .. ".db",t.db,"db")
		return true
	end
	return false
end
function save_tour_list(db)
	local dayname = get_day_name()
	comma.save_io(dayname,db,"db")
end
function add_tour(id,rounds,desks,tour_type)
	local db = load_tour_list()
	db[id] = {}
	db[id].rounds = tonumber(rounds)
	db[id].desks = tonumber(desks)
	db[id].tour_type = tour_type
  save_tour_list(db)
end
function load_master()
	local t = {}
	t.db = {}
	local func = loadfile(db_dir .. "master.db","bt",t)
	if func then func() end
	return t.db
end

function save_master(t)
	comma.save_io(db_dir .. "master.db",t,"db")
end

function load_admin(tour_no)
	local t={}
	t.db={}
	local func = loadfile(db_dir .. tour_no .. ".db","bt",t)	
	if func then func() end 
	return t.db
end

function save_admin(tour_no,t)
	comma.save_io(db_dir .. tour_no .. ".db",t,"db")
end

function auth_edit(tour_no,passwd)
	local admin = load_admin(tour_no)
	return admin.admin and admin.admin == passwd
end

function auth_desk(tour_no,round,desk,passwd)
	local db = load_db(tour_no,round,desk)
	if not db then return nil end
	return db.passwd and db.passwd == passwd
end

function auth_input(db,tour_no,passwd)
	local admin = load_admin(tour_no)
	if not db.passwd and passwd then db.passwd = passwd end
	return db.passwd == passwd or passwd == admin.admin
end

function get_sets(db,tour_no,round,desk)
	if db[tour_no] and db[tour_no][round] then
		return db[tour_no][round][desk]
	end
	return nil 
end

function get_contract_str(set,declarer,contract_num,contract_trump,contract_double,result_flag,result_num)
	local contract = set
	if declarer == "P" then
		contract = contract .. "AP"
	else
		contract = contract .. declarer .. contract_num .. contract_trump

		if contract_double == "X" or contract_double == "XX" then
			contract = contract .. contract_double
		end 

		if result_flag == "=" then
			contract = contract .. result_flag
		else
			contract = contract .. result_flag .. result_num
		end
	end 
	return contract
end

function get_tour_pls(tour_no)
	local M = {}
	M.db = {}
	local func = loadfile(db_dir .. tour_no .. "-ximp.db","bt",M)
	if func then func() end 
  local players = {}	
	for round,v in ipairs(M.db) do
		for i,v1 in ipairs(v) do
			local num = v1.no
			players[num] = players[num] or {}
			players[num].no = v1.no
			players[num].vp = players[num].vp or 0.0
			players[num].vp = players[num].vp + v1.vp
			players[num].rs = players[num].rs or {}
			players[num].rs[round] = v1.vp
		end
	end
	local pls = {}
	for k,v in pairs(players) do
		local num = #pls+1
		pls[num] = {}
		pls[num].no = k
		pls[num].vp = v.vp
		pls[num].rs = v.rs
	end
	local function cmp_vp(a,b)
		return a.vp > b.vp
	end
	table.sort(pls,cmp_vp)
	return pls
end

function load_vps(pls)
	local rs = {}
	for i,v in ipairs(pls) do
		rs[v.name] = v.total
	end
	return rs
end

function load_register_list()
	local partners = load_partner()
	local users = load_user_list()
	local pls = load_total("laotang")
	local vps = load_vps(pls)
	for i,v in ipairs(partners) do
		v.name1 = users[v.no1]
		v.name2 = users[v.no2]
		v.vp1 = vps[v.name1] or 50
		v.vp2 = vps[v.name2] or 50
		v.vp = v.vp1 + v.vp2
	end
	table.sort(partners,function(a,b) return a.vp > b.vp end)
	return partners
end

function save_ximp(tour_no,round,sets,index,players)
	local db = {}
	db.sets = sets
	db.index = index
	db.players = players
	comma.save_io(db_dir .. tour_no .. "-" .. round .. "-ximp.db",db,"db")
	local M = {}
	M.db = {}
	local func = loadfile(db_dir .. tour_no .. "-ximp.db","bt",M)
	if func then func() end 
	local r = tonumber(round) 
	M.db[r] = M.db[r] or {}
	for i,v in ipairs(players) do
		M.db[r][i] = v
	end
	comma.save_io(db_dir .. tour_no .. "-ximp.db",M.db,"db")
end

function add_bonus(tour_no,round,no1,no2,desks)
	local M = {}
	M.db = {}
	local func = loadfile(db_dir .. tour_no .. "-ximp.db","bt",M)
	if func then func() end 
	local r = tonumber(round) 
	M.db[r] = M.db[r] or {}
	local num = 4 * desks
	M.db[r][num+1] = {}
	M.db[r][num+1].no = tonumber(no1)
	M.db[r][num+1].vp = 12
	M.db[r][num+1].ximp = 0.0 
	M.db[r][num+1].mp = 0.0 
	M.db[r][num+1].boards = 0 
	M.db[r][num+2] = {}
	M.db[r][num+2].no = tonumber(no2)
	M.db[r][num+2].vp = 12
	M.db[r][num+2].ximp = 0.0 
	M.db[r][num+2].mp = 0.0 
	M.db[r][num+2].boards = 0 
	comma.save_io(db_dir .. tour_no .. "-ximp.db",M.db,"db")
end

function load_ximp(tour_no,round)
	local M = {} 
	M.db = {}
	M.db.sets = {}
	M.db.index = {}
	M.db.players = {}
	local func = loadfile(db_dir .. tour_no .. "-" .. round .. "-ximp.db","bt",M)
	if func then func() end 
	return M.db.sets,M.db.index,M.db.players
end
function save_db(tour_no,round,desk,db)
	comma.save_io(db_dir .. tour_no .. "-" .. round .. "-" .. desk .. ".db",db,"db")
end

function load_db(tour_no,round,desk)
	local M = {} 
	M.db = {}
	local func = loadfile(db_dir .. tour_no .. "-" .. round .. "-" .. desk .. ".db","bt",M)	
	if func then func() end 
	return M.db
end

function tour_round_name(tour_no,round)
	if tour_no and round then
		return tour_no .. "-" .. round
	else
		return nil
	end
end

function tour_round_desk_name(tour_no,round,desk)
	if tour_no and round and desk then
		return tour_no .. "-" .. round .. "-" .. desk 
	else
		return nil
	end
end

function lock_tour(db,tour_no,round,desk)
	if tour_no and round and desk then
		db[tour_round_desk_name(tour_no,round,desk)] = false 
		--trace_out("lock " .. tour_no .. round .. desk .. "\n")
	elseif tour_no and round then
		db[tour_round_name(tour_no,round)] = false 
		--trace_out("lock " .. tour_no .. round .. "\n")
	elseif tour_no then
		db.unlock = false
		--trace_out("lock " .. "\n")
	end
end

function unlock_tour(db,tour_no,round,desk)
	if tour_no and round and desk then
		db[tour_round_desk_name(tour_no,round,desk)] = true
	elseif tour_no and round then
		db[tour_round_name(tour_no,round)] = true
	elseif tour_no then
		db.unlock = true
	end
end

function is_desk_unlock(db,tour_no,round,desk)
	return db[tour_round_desk_name(tour_no,round,desk)]
end

function is_round_unlock(db,tour_no,round,desk)
	return db[tour_round_name(tour_no,round)]
end

function is_unlock(db,tour_no,round,desk)
	return is_desk_unlock(db,tour_no,round,desk) or is_round_unlock(db,tour_no,round,desk)
end

function get_desk_sets(desk,tour_no,round,passwd) 
	local db = load_admin(tour_no)
	local unlock = is_unlock(db,tour_no,round,desk)
	local t 

	local M = {} 
	local func = loadfile(db_dir .. tour_no .. "-" .. round .. "-" .. desk .. ".db","bt",M)	
	if func then func() end 
	if M.db and M.db[tour_no] and M.db[tour_no][round] then																	 
		t = M.db[tour_no][round][desk]	
	end

	local flag = unlock or ( M.db and M.db.passwd and passwd and M.db.passwd == passwd)

	if flag then
		return t
	else
		return nil
	end
end	

function get_score(str)
	local ok,score = luabridge.score(str) 
	local con_str
	local flag,set,declarer,num,trump,double,redouble,result = luabridge.farse_contract(str) 
	if not flag then
		con_str = "AP" 
	else
		con_str = declarer .. num .. trump 
		if double then con_str = con_str .. "X" end
		if redouble then con_str = con_str .. "XX" end 
		if result and result == 0 then
			result = "="
		elseif result and result > 0 then
			result = "+" .. result 
		elseif result then
			result = tostring(result)
		end
		if result then
			con_str = con_str .. result
		end
	end
	return con_str,score
end

function fill_index(M,t,i)
	if not t then return end
	for k,v in pairs(t) do
		M[k] = M[k] or {} 
		M[k][i] = {}
		local con_str,score = get_score(v.contract)
		M[k][i].str = con_str 
		M[k][i].score = score
	end
end

function total_imp(t)
	local num1 = 0
	local num2 = 0
	for k,v in pairs(t) do
		if v[1] and v[1].imp then num1 = num1 + v[1].imp
		elseif v[2] and v[2].imp then num2 = num2 + v[2].imp
		end
	end
	return num1,num2
end

function cal_imp(t)
	for k,v in pairs(t) do
		if v[1] and v[2] and v[1].score and v[2].score then
			local s = v[1].score - v[2].score
			local imp = luabridge.imp(s) 
			if imp > 0 then
				v[1].imp = imp
			elseif imp < 0 then
				v[2].imp = -imp
			end
		end
	end
end

function vp(boards,imp)
	return luabridge.vp(boards,imp)
end

local function mk_index(sets)
	local index = {}
	for k,v in pairs(sets) do
		table.insert(index,k)
	end
	table.sort(index)
	return index
end

function txs_sum(data,desks)
	local NS = {}
	local EW = {}
	if data and desks then
		for i=1,desks do
			NS[i] = {boards=0,mp=0.0,ximp=0.0,no=i}
			EW[i] = {boards=0,mp=0.0,ximp=0.0,no=i}
		end
		for i,v in ipairs(data) do
			NS[v.NS].mp = NS[v.NS].mp + v.NS_mp
			NS[v.NS].ximp = NS[v.NS].ximp + v.NS_ximp
			NS[v.NS].boards = NS[v.NS].boards + 1

			EW[v.EW].mp = EW[v.EW].mp + v.EW_mp
			EW[v.EW].ximp = EW[v.EW].ximp + v.EW_ximp
			EW[v.EW].boards = EW[v.EW].boards + 1
		end

		local function cmp_mp(a,b)
			return a.mp > b.mp
		end
		table.sort(NS,cmp_mp)
		table.sort(EW,cmp_mp)
	end
	return NS,EW
end

function txs_cal(data)
	local sets = luabridge.mk_sets(data)  -- {[6]={set,set,set},[7]={record,record}}
	local index = mk_index(sets)    --{6,7,8....}
	for i,v in ipairs(index) do
		local rs = sets[v]   --rs = {set,set,set}
		if rs and #rs > 1 then
			luabridge.mp_sets(rs)
			luabridge.ximp_sets(rs)
		end
	end
end
function tour_ximp(data)
	local sets = luabridge.mk_sets(data)  -- {[6]={set,set,set},[7]={record,record}}
	local index = mk_index(sets)    --{6,7,8....}
	for i,v in ipairs(index) do
		local rs = sets[v]   --rs = {set,set,set}
		if rs and #rs > 1 then
			luabridge.mp_sets(rs)
			luabridge.ximp_sets(rs)
		end
	end
	local players = {}
	for i,v in ipairs(data) do
		if v.N and v.S and v.E and v.W then
			players[v.N] = players[v.N] or {}
			players[v.S] = players[v.S] or {}
			players[v.E] = players[v.E] or {}
			players[v.W] = players[v.W] or {}

			players[v.N].boards = players[v.N].boards or 0
			players[v.N].boards = players[v.N].boards + 1
			players[v.N].ximp = players[v.N].ximp or 0.0
			players[v.N].ximp = players[v.N].ximp + v.NS_ximp
			players[v.N].mp = players[v.N].mp or 0.0
			players[v.N].mp = players[v.N].mp + v.NS_mp

			players[v.S].boards = players[v.S].boards or 0
			players[v.S].boards = players[v.S].boards + 1
			players[v.S].ximp = players[v.S].ximp or 0.0
			players[v.S].ximp = players[v.S].ximp + v.NS_ximp
			players[v.S].mp = players[v.S].mp or 0.0
			players[v.S].mp = players[v.S].mp + v.NS_mp

			players[v.E].boards = players[v.E].boards or 0
			players[v.E].boards = players[v.E].boards + 1
			players[v.E].ximp = players[v.E].ximp or 0.0
			players[v.E].ximp = players[v.E].ximp + v.EW_ximp
			players[v.E].mp = players[v.E].mp or 0.0
			players[v.E].mp = players[v.E].mp + v.EW_mp

			players[v.W].boards = players[v.W].boards or 0
			players[v.W].boards = players[v.W].boards + 1
			players[v.W].ximp = players[v.W].ximp or 0.0
			players[v.W].ximp = players[v.W].ximp + v.EW_ximp
			players[v.W].mp = players[v.W].mp or 0.0
			players[v.W].mp = players[v.W].mp + v.EW_mp
		end
	end
	local pls = {}
	for k,v in pairs(players) do
		local num = #pls+1
		pls[num] = {}
		pls[num].no = k
		pls[num].boards = v.boards
		pls[num].ximp = v.ximp
		pls[num].mp = v.mp
		pls[num].vp = luabridge.vp(v.boards,v.ximp)
	end
	local function cmp_vp(a,b)
		return a.vp > b.vp
	end
	table.sort(pls,cmp_vp)
	return sets,index,pls
end

function load_tour_desk_sets(tour_no,round,desk,sets)
	local round = tostring(round)
	local desk = tostring(desk)
	local db = load_db(tour_no,round,desk)
	sets = sets or {}
	local conts = get_sets(db,tour_no,round,desk) or {}
	for k,v in pairs(conts) do
		local set = {}
		set.round = round
		set.table = desk
		set.board = k
		set.N = db.N_no 
		set.S = db.S_no 
		set.E = db.E_no 
		set.W = db.W_no 
		set.constr,set.score = get_score(v.contract)
		table.insert(sets,set)
	end
end

function load_tour_sets(tour_no,round)
	local tour_list = load_tour_list()
	local desks = tour_list[tour_no].desks or 0
	local sets = {}
	for j=1,desks do
		load_tour_desk_sets(tour_no,tonumber(round),j,sets)
	end
	return sets
end

function load_txs_sets(tour_no)
	local db = load_admin(tour_no)  	
	if not db.unlock then
		return {},{} 
	end
	local sets = {}
	db.rounds = db.rounds or 0
	db.desks = db.desks or 0
	for i=1,db.rounds do
		for j=1,db.desks do
			load_desk_sets(tour_no,i,j,sets,db.round[i][j].NS,db.round[i][j].EW)
		end
	end
	return sets,db
end

function load_desk_sets(tour_no,round,desk,sets,NS,EW)
	local round = tostring(round)
	local desk = tostring(desk)
	local db = load_db(tour_no,round,desk)
	sets = sets or {}
	local conts = get_sets(db,tour_no,round,desk) or {}
	for k,v in pairs(conts) do
		local set = {}
		set.round = round
		set.table = desk
		set.board = k
		set.NS = NS
		set.EW = EW
		set.constr,set.score = get_score(v.contract)
		table.insert(sets,set)
	end
end

function bgl(m)
	local result = {}
	local a =1
	local b =1
	local index = 1
	local loop = 0

	local iter = 0
	--print([[round_data = {}]])
	for i=1,(m-1)*(m/2) do
		if a>=m then a = 1 end
		if index > m/2 then index = 1 end
		if index == 1 then
			loop = loop +1
			if i==1 then 
				b=m
			else
				b=a
			end
			--print("round_data[" .. loop .. "] = {}" )
			result[loop] = {}
			iter = 0	
			if (((i-1)/(m/2))%2 == 0) then
				iter = iter + 1
				result[loop][iter] = a
				--print("round_data[" .. loop .. "][" .. iter .. "] = " .. a)
				iter = iter + 1
				result[loop][iter] = m
				--print("round_data[" .. loop .. "][" .. iter .. "] = " .. m)
			else
				iter = iter + 1
				result[loop][iter] = m
				--print("round_data[" .. loop .. "][" .. iter .. "] = " .. m)
				iter = iter + 1
				result[loop][iter] = a
				--print("round_data[" .. loop .. "][" .. iter .. "] = " .. a)
			end

		elseif (index >1 and index <= m/2) then
			if b>1 then b= b-1
			else b = m -1
			end
			iter = iter + 1
			result[loop][iter] = a
			--print("round_data[" .. loop .. "][" .. iter .. "] = " .. a)
			iter = iter + 1
			result[loop][iter] = b
			--print("round_data[" .. loop .. "][" .. iter .. "] = " .. b)
		end
		index = index + 1
		a = a + 1
	end

	return result
end


