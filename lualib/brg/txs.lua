local modename = ...
local M = {}
_G[modename] = M
package.loaded[modename] = M

local trace_out = trace_out

_ENV = M

local total_sets = 24
local valid_round = { 0,0,2,2,4,4,6,6,8,8,8,8,12,12,12,12,12,12}

local function mv_EW(round,desk,temp,desk_info,desks,jump_round)
	local EW  = desk_info[desk].EW - 1
	if round == jump_round then EW = EW -1 end
	if EW <= 0  then EW = EW + desks end
	desk_info[desk].EW = EW
	temp.EW = EW
end

local function mv_board(desk,temp,desk_info,max_sets,sets_perround)
	local num = desk_info[desk].l + sets_perround
	if num > max_sets then num = num - max_sets end 
	temp.l = num
	desk_info[desk].l = num
	temp.h = num + sets_perround - 1
end

function get_rounds(desks)
	if desks < 3 or desks > 18 then
		return 0 
	end
	return valid_round[desks]
end

function txs_round(desks)
	if desks < 3 or desks > 18 then
		return nil
	end
	local jump_round = 0
	local rounds
	local sets_perround
	local max_sets
	local desk_info = {}

	if desks % 2 == 0 then
		jump_round = desks / 2
	end

	rounds = valid_round[desks]
	sets_perround = total_sets // rounds
	max_sets = sets_perround * desks

	for i =1,desks do
		desk_info[i] = {}
		desk_info[i].NS = i
		desk_info[i].EW = i
		desk_info[i].boards = {}
		desk_info[i].l = 1 + (i - 1) * sets_perround
	end

	round_data = {}
	for i = 1,rounds do
		round_data[i] = {}
		for j = 1,desks do
			round_data[i][j] = {}
			local temp = {}
			temp.section = 1
			temp.round = i
			temp.table = j
			temp.NS = desk_info[j].NS
			mv_EW(i,j,temp,desk_info,desks,jump_round)
			mv_board(j,temp,desk_info,max_sets,sets_perround)
			round_data[i][j].NS = temp.NS
			round_data[i][j].EW = temp.EW
			round_data[i][j].l = temp.l
			round_data[i][j].h = temp.h
		end 		
	end
	return round_data
end

