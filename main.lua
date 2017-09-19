local http_svr = mq.new("service/http.lua")
local websocket_svr = mq.new("service/websocket.lua")
local listen_s =  hub_start("localhost",80,10,http_svr) --ip port max_accept max_accept_seconds
local web_s = hub_start("localhost",8001,10,websocket_svr)

function quit()
	remove_content(listen_s)
	remove_content(web_s)
end

