local luaext = require("luaext")
local agent = {}
local max_agents = 10
for i=1,max_agents do
	agent[i] = mq.new("service/hub.lua","agent:" .. i)
end
local index = 1

function ghub.services.accept(content)
	link_iocp(content,agent[index])
	index = index + 1
	if index > max_agents then index = 1 end
	post_recv(content,luaext.guid())
end
