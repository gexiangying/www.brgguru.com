local modename = ...
local M ={}
_G[modename] = M
package.loaded[modename] = M

local string = string
local pairs = pairs
local tonumber = tonumber
_ENV = M

function code(t)
	local str
	for k,v in pairs(t) do
   if str and k and v then
		 str = str .. "&" .. escape(k) .. "=" .. escape(v)
	 elseif k and v then
		 str = escape(k) .. "=" ..escape(v)
	 end
	end
	return str
end

function unescape(s)
	s = string.gsub(s,"+"," ")
	s = string.gsub(s,"%%(%x%x)",function(h)
		return string.char(tonumber(h,16))
	end)
	return s
end

function escape(s)
	s = string.gsub(s,"[&=+%%%c]",function(c)
		return string.format("%%%02X",string.byte(c))
	end)
	s = string.gsub(s," ","+")
	return s
end


