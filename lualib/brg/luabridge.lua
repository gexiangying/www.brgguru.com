local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M 
-----------------------------------------------------
local string = string
local tonumber = tonumber
local math = math
local ipairs = ipairs
local table = table
------------------------------------------------------
_ENV = M


local function get_score(valide,set,declare,num,trump,double,redouble,result)
	local vuls = { {false,false},{true,false},{false,true},{true,true},
	{true,false},{false,true},{true,true},{false,false},
	{false,true},{true,true},{false,false},{true,false},
	{true,true},{false,false},{true,false},{false,true}}
	if not valide then return valide,0 end
	local rs = 0
	local one_trick = 0
	local little_slam = num == 6
	local big_slam = num == 7

	set = set % 16
	if set == 0 then set = 16 end
	if not declare then return 0 end

	local vul = vuls[set]
	local NS = 1
	local EW = 2
	local vul_flag = false
	if declare == "N" or declare == "n" or declare == "S" or declare == "s" then
		vul_flag = vul[NS]
	elseif declare == "E" or declare == "e" or declare == "W" or declare == "w" then
		vul_flag = vul[EW]
	end

	if trump == "C" or trump == "D" then
		one_trick = 20
	elseif trump == "S" or trump == "H" then
		one_trick = 30
	elseif trump == "NT" then
		rs = 40
		num = num -1
		one_trick = 30
	end

	if result >= 0 then
		----basic score ----
		rs = rs +	num * one_trick
		if double then 
			rs = rs * 2 
		elseif redouble then 
			rs = rs * 4
		end	
		--basic score end-------------

		----bonus----
		if rs < 100 then 
			rs = rs + 50
		else
			---game bonus -----
			if vul_flag then 
				rs = rs + 500
			else
				rs = rs + 300
			end
			---little slame ---
			if vul_flag and little_slam then 
				rs = rs + 750 
			elseif little_slam then
				rs = rs + 500
			end
			---big slame -----

			if vul_flag and big_slam then 
				rs = rs + 1500 
			elseif big_slam then
				rs = rs + 1000 
			end
		end
		-----double redouble ----
		if double then
			rs = rs + 50
			if vul_flag then
				rs = rs + result * 200
			else
				rs = rs + result * 100
			end
		elseif redouble then
			rs = rs + 100
			if vul_flag then
				rs = rs + result * 400
			else
				rs = rs + result * 200
			end
		else
			rs = rs + result * one_trick
		end
		------bonus end----
	else
		----punish score ----
		rs = 0
		if not vul_flag then
			if double or redouble then
				if result > -4 then
					rs = rs + (result + 1) * 200 -100
				else
					rs = rs + (result + 4) * 300 -800
				end
				if redouble then rs = rs *2 end
			else
				rs = result * 50
			end
		else	
			if double or redouble then
				rs = rs + (result + 1)*300 -200
				if redouble then rs = rs * 2 end
			else
				rs = rs + result * 100
			end
		end
	end
	if(declare == "E" or declare == "W") then
		rs = -rs
	end
	return valide,rs
end

function farse_contract(str)

	local set,declare,num,trump,double,redouble,result,dstr
  str = string.upper(str)
	set,declare,num,trump,dstr,result = string.match(str,"(%d+)(%a)(%d)([SHDCNT]+)([X]*)([+-=]?%d*)")

	if not set or not declare or not num or not trump or not result then
		return false
	end

	set = tonumber(set)
	num = tonumber(num)

	if result == "=" then
		result = 0
	else
		result = tonumber(result)
	end

	if dstr and dstr == "X" then
		double = true
		redouble = false
	elseif dstr and dstr == "XX" then
		double = false
		redouble = true
	else
		double = false
		redouble = false
	end
	return true,set,declare,num,trump,double,redouble,result
end

function score(str)
	local rs = 0
	local flag = false
	str = string.upper(str)
	if str == "AP" or str == "PASS" then
		return true,0
	else
		flag,rs = get_score(farse_contract(str))
	end
	return flag,rs
end

function imp(score)
	local rs = 0
	local flag = 1
	if score < 0 then
		flag  = -1
		score = -score
	end
	local imp_score={4000,3500,3000,2500,2250,2000,1750,1500,1300,1100,900,750,600,500,430,370,320,270,220,170,130,90,50,20,0}
	local max = #imp_score 
	local index = 1
	while imp_score[index] > score do
		index = index + 1
	end
	rs = flag * (max - index)
	return rs
end

function vp(boards,imp)
	if boards < 1 then return 0.0 end
	flag = true
	if imp < 0.0 then
		flag = false
		imp = -imp 
	end
	local a = (math.sqrt(5) - 1) / 2
	local b = imp / ( 5 * math.sqrt(boards))
	if b > 3 then b = 3 end
	local z = 10 * ( 1 - a^b) /  (1 - a^3)
	z = z + 0.005
	if flag then
		return 10 + z - z % 0.01
	else
		return 10 - (z - z % 0.01) 
	end
end

function floor_num(n)
	return math.floor(n * 100)/100
end

function init_result_item(t)
	t.mp = t.mp or 0.0
	t.ximp = t.ximp or 0.0
	t.imp = t.imp or 0.0
	t.plus = t.plus or 0
	t.minus = t.minus or 0
	t.num = t.num or 0
end

function cal_im_EW(sets,result)
	for i,v in ipairs(sets) do
		local ew_name = "EW" .. v.EW
		result[ew_name] = result[ew_name] or {}
		local t = result[ew_name]
		init_result_item(t) 
		t.mp = t.mp + v.EW_mp
		t.ximp = t.ximp + v.EW_ximp
		t.num = t.num + 1
		t.no = v.EW
		if(v.EW_imp >0) then 
			t.plus = t.plus + v.EW_imp 
		else
			t.minus = t.minus - v.EW_imp
		end
	end
end 



function cal_im_NS(sets,result)
	for i,v in ipairs(sets) do
		local ns_name = "NS" .. v.NS
		result[ns_name] = result[ns_name] or {}
		local t = result[ns_name]
		init_result_item(t) 
		t.mp = t.mp + v.NS_mp
		t.no = v.NS
		t.section = v.section
		t.ximp = t.ximp + v.NS_ximp
		t.num = t.num + 1
		if(v.NS_imp >0) then 
			t.plus = t.plus + v.NS_imp 
		else
			t.minus = t.minus - v.NS_imp
		end
	end
end 

function cal_sets_EW(sets)
	local result = {}
	for k,v in ipairs(sets) do
		cal_im_EW(v,result)
	end 
	return result
end


function cal_sets_NS(sets)
	local result = {}
	for k,v in ipairs(sets) do
		cal_im_NS(v,result)
	end 
	return result
end

function mk_sets_nil(t)
	local sets = {}
	for i,v in ipairs(t) do
		sets[v.board] = sets[v.board] or {}
		table.insert(sets[v.board],v)
	end
	return sets
end

function mk_sets_round_table(t,round,desk)
	local sets = {}
	for i,v in ipairs(t) do
		if v.round == round  and v.table == desk then
			sets[v.board] = sets[v.board] or {}
			table.insert(sets[v.board],v)
		end 
	end
	return sets
end


function mk_sets_round(t,round)
	local sets = {}
	for i,v in ipairs(t) do
		if v.round == round then
			sets[v.board] = sets[v.board] or {}
			table.insert(sets[v.board],v)
		end 
	end
	return sets
end

function mk_sets(t,round,desk)
	if desk then
		return mk_sets_round_table(t,round,desk)
	elseif round then
		return mk_sets_round(t,round)
	else
		return mk_sets_nil(t)
	end
end

function imp_im(t,sets)
	local num = 0.0
	for i,v in ipairs(sets) do
		if t.table == v.table then 
			local score = t.score - v.score
			num = num + imp(score)
		end
	end
	t.NS_imp = num 	
	t.EW_imp = -t.NS_imp
end

function imp_sets(sets)
	for i,v in ipairs(sets) do
		imp_im(v,sets)
	end
end

function ximp_im(t,sets)
	local num = 0.0
	for i,v in ipairs(sets) do
		local score = t.score - v.score
		num = num + imp(score)
	end
	t.NS_ximp = num /(#sets -1) 	
	t.NS_ximp = floor_num(t.NS_ximp)
	t.EW_ximp = -t.NS_ximp
end
function ximp_sets(sets)
	for i,v in ipairs(sets) do
		ximp_im(v,sets)
	end
end
function mp_im(t,sets)
	local num = 0.0
	for i,v in ipairs(sets) do
		if t.score > v.score then
			num = num + 1.0
		elseif t.score == v.score then
			num = num + 0.5
		end
	end
	num = num - 0.5;
	t.NS_mp = num * 100 /(#sets -1) 
	t.NS_mp = floor_num(t.NS_mp)  
	t.EW_mp = 100 - t.NS_mp
end

function mp_sets(sets)
	for i,v in ipairs(sets) do
		mp_im(v,sets)
	end
end


