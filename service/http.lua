local luaext = require("luaext")
local agent = {}
for i=1,20 do
	agent[i] = mq.new("service/hub.lua",true)
end
local index = 1

function ghub.services.accept(content)
	link_iocp(content,agent[index])
	index = index + 1
	if index > 20 then index = 1 end
	post_recv(content,luaext.guid())
end
