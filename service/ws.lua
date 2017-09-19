package.path = package.path .. ";./lualib/?.lua"
package.cpath = "?53.dll;?.dll;" .. package.cpath
luaext = require("luaext")

local cts = {}

function ghub.services.link(content,str)
	trace_out("link .. target:" .. str .. "\n")
	cts[content] = true
end

function ghub.services.quit(content)
	if cts[content] then
		ip,port = hub_addr(content)
		trace_out("ws client exit @" .. ip .. ":" ..port .. "\n")
		remote_content(content)
		cts[content] = nil
	end
end

function ghub.services.recv(content,str)
	post_recv(content,luaext.guid())
end


