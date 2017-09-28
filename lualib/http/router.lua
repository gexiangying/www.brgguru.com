local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M

local string = string
local ipairs = ipairs
local pairs = pairs

_ENV = M

local sites={
	"www.apcad.com",
	"apcad.com",
	"www.brgguru.com",
	"brg.brgguru.com",
	"127.0.0.1",
	"localhost",
	"jquery.brgguru.com",
	"default"
}
local routes = {}
routes["127.0.0.1"] = { ["path"] ="c:\\gexy\\three.js-master\\three.js-master\\examples",["name"] ="index",["ext"]="lp"}
routes["localhost"] = { ["path"] ="apcad",["name"] ="index",["ext"]="lp"}
routes["jquery.brgguru.com"] = { ["path"] ="jquery",["name"] ="index",["ext"]="lp"}
routes["www.apcad.com"] = routes["localhost"] 
routes["apcad.com"] = routes["localhost"] 
routes["www.brgguru.com"] = routes["127.0.0.1"] 
routes["brg.brgguru.com"] = routes["127.0.0.1"] 
routes["default"] = routes["127.0.0.1"] 

function dispatch(cgi,host)
	host = host or "default"
	local route = routes["default"]
	for i,v in ipairs(sites) do
		if string.find(host,v) then
			route = routes[v]
			break
		end
	end
	if cgi.path then
		cgi.path = route.path .. cgi.path .. "/"
		cgi.path = string.gsub(cgi.path,route.path .. "/jquery","jquery")
	else
		cgi.path = route.path .. "/"
	end
	cgi.filename = cgi.filename or route.name 
	cgi.fileext = cgi.fileext or route.ext
end
