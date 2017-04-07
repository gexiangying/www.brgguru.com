--liaoning ICP 16001504 password = "YFK787"
hub_start("localhost",8080,10,60,true,false,"hub.lua") --ip port max_accept max_accept_seconds,hubmode,accept and recv

function socket_quit(content)
	ip,port = hub_addr(content)
	local exittime = os.date("%x %X")
	trace_out("unkown client exit @" .. ip .. ":" .. port .. "---" .. exittime .. "\n")
end

function on_quit()
end

