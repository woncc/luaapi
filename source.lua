module("source",package.seeall)
local http = require "resty.http"
local sock = ngx.socket.tcp()
local string_find, string_sub, string_format = string.find, string.sub, string.format
local table_concat, table_insert = table.concat, table.insert

function check(req, resp) 
	resp.headers['Content-Type'] = 'text/html; charset=utf-8'
	req:read_body()
	if req.method == 'POST' then
		sock:settimeout(3000)
		local ips = req:get_arg('ip')
		local port = req:get_arg('port')
		local host = req:get_arg('host')
		local tmp = split_by_char(ips, '.')

		for i=0,255 do
			local ip = tmp[1] .. '.' .. tmp[2] .. '.' .. tmp[3] .. '.' .. i
			local ok, err = sock:connect(ip, port)
			if not ok then
				ngx.say("failed to connect: ", err, v)

			else

				local req = "GET / HTTP/1.1\r\nHost: ".. host .."\r\nConnection: close\r\n\r\n"

				local bytes, err = sock:send(req)
				if not bytes then
					ngx.say("failed to send request: ", err)
				else
					ngx.say("cnnect ok:\t", ip)
				end
			end
		end

		--resp:writeln(req:get_arg('ip[]'))
	end


	local ip = mysql.Mysql:getServerIp()
	local content = {
		ip = ip,
	}
	resp:tpl(content, config:get('templatedir')..'/check.html')
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
