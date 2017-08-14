local http_svr = mq.new("service/http.lua")
local listen_s =  hub_start("localhost",8080,10,http_svr) --ip port max_accept max_accept_seconds

function quit()
	remove_content(listen_s)
end

