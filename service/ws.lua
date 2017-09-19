package.path = package.path .. ";./lualib/?.lua"
package.cpath = "?53.dll;?.dll;" .. package.cpath

local luaext = require("luaext")
local cts = {}
local ws = {}
local ws_mt = { __index = ws }

local function read(self,n)
	while string.len(self.buf) < n do
		local str = mq.recv(self.id)
		if str then
			self.buf = self.buf .. str
		else
			break
		end
	end
	local str = string.sub(self.buf,1,n)
	self.buf = string.sub(self.buf,n+1)
	return str
end

local H = {}
function H.check_origin_ok(origin, host)
    --return urllib.parse(origin) == host
		return true
end

function H.on_open(ws)
	trace_out("H websocket open!\n")    
end

function H.on_message(ws, message)
	trace_out("H websocket message:" .. message .. "!\n")    
end

function H.on_close(ws, code, reason)
   trace_out("H websocket close\n") 
end

function H.on_pong(ws, data)

end



function ws:send_frame(fin, opcode, data)
    local finbit, mask_bit
    if fin then
        finbit = 0x80
    else
        finbit = 0
    end

    local frame = string.pack("B", finbit | opcode)
    local l = #data

    if self.mask_outgoing then
        mask_bit = 0x80
    else
        mask_bit = 0
    end

    if l < 126 then
        frame = frame .. string.pack("B", l | mask_bit)
    elseif l < 0xFFFF then
        frame = frame .. string.pack(">BH", 126 | mask_bit, l)
    else 
        frame = frame .. string.pack(">BL", 127 | mask_bit, l)
    end

    if self.mask_outgoing then
    end

    frame = frame .. data

    hub_send(self.id, frame)
end

function ws:send_text(data)
    self:send_frame(true, 0x1, data)
end

function ws:send_binary(data)
    self:send_frame(true, 0x2, data)
end


function ws:send_ping(data)
    self:send_frame(true, 0x9, data)
end


function ws:send_pong(data)
    self:send_frame(true, 0xA, data)
end

function ws:close(code, reason)
    -- 1000  "normal closure" status code
    if not self.server_terminated then
        if code == nil and reason ~= nil then
            code = 1000
        end
        local data = ""
        if code ~= nil then
            data = string.pack(">H", code)
        end
        if reason ~= nil then
            data = data .. reason
        end
        self:send_frame(true, 0x8, data)

        self.server_terminated = true
    end

    if self.client_terminated then
        --socket.close(self.id)
    end
end

local function websocket_mask(mask, data, length)
    local umasked = {}
    for i=1, length do
        umasked[i] = string.char(string.byte(data, i) ~ string.byte(mask, (i-1)%4 + 1))
    end
    return table.concat(umasked)
end


function ws:recv_frame()
    local data, err = read(self, 2)

    if not data then
        return false, nil, "Read first 2 byte error: " .. err
    end

    local header, payloadlen = string.unpack("BB", data)
    local final_frame = header & 0x80 ~= 0
    local reserved_bits = header & 0x70 ~= 0
    local frame_opcode = header & 0xf
    local frame_opcode_is_control = frame_opcode & 0x8 ~= 0

    if reserved_bits then
        -- client is using as-yet-undefined extensions
        return false, nil, "Reserved_bits show using undefined extensions"
    end

    local mask_frame = payloadlen & 0x80 ~= 0
    payloadlen = payloadlen & 0x7f

    if frame_opcode_is_control and payloadlen >= 126 then
        -- control frames must have payload < 126
        return false, nil, "Control frame payload overload"
    end

    if frame_opcode_is_control and not final_frame then
        return false, nil, "Control frame must not be fragmented"
    end

    local frame_length, frame_mask

    if payloadlen < 126 then
        frame_length = payloadlen

    elseif payloadlen == 126 then
        local h_data, err = read(self, 2)
        if not h_data then
            return false, nil, "Payloadlen 126 read true length error:" .. err
        end
        frame_length = string.unpack(">H", h_data)

    else --payloadlen == 127
        local l_data, err = read(self, 8)
        if not l_data then
            return false, nil, "Payloadlen 127 read true length error:" .. err
        end
        frame_length = string.unpack(">L", l_data)
    end


    if mask_frame then
        local mask, err = read(self, 4)
        if not mask then
            return false, nil, "Masking Key read error:" .. err
        end
        frame_mask = mask
    end

    --print('final_frame:', final_frame, "frame_opcode:", frame_opcode, "mask_frame:", mask_frame, "frame_length:", frame_length)

    local  frame_data = ""
    if frame_length > 0 then
        local fdata, err = read(self, frame_length)
        if not fdata then
            return false, nil, "Payload data read error:" .. err
        end
        frame_data = fdata
    end

    if mask_frame and frame_length > 0 then
        frame_data = websocket_mask(frame_mask, frame_data, frame_length)
    end


    if not final_frame then
        return true, false, frame_data
    else
        if frame_opcode  == 0x1 then -- text
            return true, true, frame_data
        elseif frame_opcode == 0x2 then -- binary
            return true, true, frame_data
        elseif frame_opcode == 0x8 then -- close
            local code, reason
            if #frame_data >= 2 then
                code = string.unpack(">H", frame_data:sub(1,2))
            end
            if #frame_data > 2 then
                reason = frame_data:sub(3)
            end
            self.client_terminated = true
            --self:close()
            self.handler.on_close(self, code, reason)
        elseif frame_opcode == 0x9 then --Ping
            self:send_pong()
        elseif frame_opcode == 0xA then -- Pong
            self.handler.on_pong(self, frame_data)
        end

        return true, true, nil
    end

end


function ws:recv()
    local data = ""
    while true do
        local success, final, message = self:recv_frame()
        if not success then
            return success, message
        end
        if final and message then
            data = data .. message
            break
        else
            data = data .. message
        end
    end
    self.handler.on_message(self, data)
end


function ws.new(id,handler,conf)
	local conf = conf or {}
	local handler = handler or {}

	setmetatable(handler, { __index = H })
	local self = {
        id = id,
        handler = handler,
        client_terminated = false,
        server_terminated = false,
        mask_outgoing = conf.mask_outgoing,
        check_origin = conf.check_origin
    }

    self.handler.on_open(self)
    return setmetatable(self, ws_mt)
end

function ghub.services.link(content,str)
	cts[content] = ws.new(content)
	cts[content]:send_text("hello websocket")
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
	if(cts[content]) then
		cts[content].buf = str
		cts[content]:recv()	
	end
	post_recv(content,luaext.guid())
end


