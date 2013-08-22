module("tools",package.seeall)
local http = require "resty.http"
local sock = ngx.socket.tcp()
local string_find, string_sub, string_format = string.find, string.sub, string.format
local table_concat, table_insert = table.concat, table.insert

function zuhe(req, resp) 
	resp.headers['Content-Type'] = 'text/html; charset=utf-8'
	req:read_body()
	local ip = ''
	if req.method == 'POST' then
		local ip = req:get_args['ip']
		ngx.say(ip)
	end

	local content = {
		ip = ip,
	}
	resp:tpl(content, config:get('templatedir')..'/tools/zuhe.html')
end

function split_by_char(str, div)
  local result = false
  if div ~= "" then
    local pos = 0
    result = {}

    if str ~= "" then
      -- for each divider found
      for st, sp in function() return string_find(str, div, pos, true) end do
        -- Attach chars left of current divider
        table_insert(result, string_sub(str, pos, st - 1))
        pos = sp + 1 -- Jump past current divider
      end
      -- Attach chars right of last divider
      table_insert(result, string_sub(str, pos))
    end
  end
  return result
end
