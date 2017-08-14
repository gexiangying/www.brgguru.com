local modename = ...
local M ={}
_G[modename] = M
package.loaded[modename] = M

local ipairs, next, pairs, tonumber, type = ipairs, next, pairs, tonumber, type
local string = string
local table = table

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
	s = string.gsub (s, "\r\n", "\n")
	return s
end

function escape(s)
	s = string.gsub (s, "\n", "\r\n")
	s = string.gsub(s,"[&=+%%%c]",function(c)
		return string.format("%%%02X",string.byte(c))
	end)
	s = string.gsub(s," ","+")
	return s
end

----------------------------------------------------------------------------
-- Insert a (name=value) pair into table [[args]]
-- @param args Table to receive the result.
-- @param name Key for the table.
-- @param value Value for the key.
-- Multi-valued names will be represented as tables with numerical indexes
--	(in the order they came).
----------------------------------------------------------------------------
function insertfield (args, name, value)
	if not args[name] then
		args[name] = value
	else
		local t = type (args[name])
		if t == "string" then
			args[name] = {
				args[name],
				value,
			}
		elseif t == "table" then
			table.insert (args[name], value)
		else
			error ("CGILua fatal error (invalid args table)!")
		end
	end
end

----------------------------------------------------------------------------
-- Parse url-encoded request data 
--   (the query part of the script URL or url-encoded post data)
--
--  Each decoded (name=value) pair is inserted into table [[args]]
-- @param query String to be parsed.
-- @param args Table where to store the pairs.
----------------------------------------------------------------------------
function parsequery (query, args)
	if type(query) == "string" then
		local insertfield, unescape = insertfield, unescape
		string.gsub (query, "([^&=]+)=([^&=]*)&?",
			function (key, val)
				insertfield (args, unescape(key), unescape(val))
			end)
	end
end

----------------------------------------------------------------------------
-- URL-encode the elements of a table creating a string to be used in a
--   URL for passing data/parameters to another script
-- @param args Table where to extract the pairs (name=value).
-- @return String with the resulting encoding.
----------------------------------------------------------------------------
function encodetable (args)
  if args == nil or next(args) == nil then   -- no args or empty args?
    return ""
  end
  local strp = ""
 for key, vals in pairs(args) do
    if type(vals) ~= "table" then
      vals = {vals}
    end
    for i,val in ipairs(vals) do
      strp = strp.."&"..escape(key).."="..escape(val)
    end
  end
  -- remove first & 
  return string.sub(strp,2)
end

