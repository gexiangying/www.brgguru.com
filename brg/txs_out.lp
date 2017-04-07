<%
local tour = _G.require("brg.tour")
local luabridge = _G.require("brg.luabridge")
local sets,db = tour.load_txs_sets(id)
tour.txs_cal(sets)
local data = luabridge.mk_sets(sets)
local f1 = _G.io.open(id .. ".txt","w")
for i,v in _G.ipairs(data) do
	for k,u in _G.ipairs(v) do
	f1:write(u.score .. "\n")
	end
end
f1:close()
%>
