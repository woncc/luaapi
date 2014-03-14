module("server",package.seeall)
local http = require "resty.http"
local sock = ngx.socket.tcp()
--local xml = require("resty.LuaXML") --need put to init_by_lua,otherwise lua_code_cache on error

function ips() 
	local ip = mysql.Mysql:getServerIp()
	for _, v in pairs(ip) do
	    ngx.say(v.ip)
	end
end
function ipinfo(req, resp)
	if not req:get_arg('ip') then ngx.print("ip is empty");ngx.exit(ngx.HTTP_OK) end
    local hc = http:new()
    local ok, code, headers, status, body  = hc:request {
        url = "http://" .. req:get_arg('ip') .. ":59188/core.whm?whm_call=info",
        timeout = 3000,
        user = config:get('kangleuser'),
        password = config:get('kanglepass'),
    }

	if ok == nil then
		ngx.print(req:get_arg('ip') .. "\ttimeout")
	else
		local doc = xml.eval(body)
		ngx.print(req:get_arg('ip') .. "\tversion:" .. doc:find("version")[1]	.. "\tconnect:" .. doc:find("connect")[1]	.. "\tvh:" .. doc:find("vh")[1])	
	end	
end

function info(req, resp)

	local ip = mysql.Mysql:getServerIp()
	--[[ips = {}二维数组
	ips[1] = {}
	ips[1]["ip"] = "45.238.236.226"]]--
	local reqs = {}
	for _, v in pairs(ip) do
		-- multi capture   
	    table.insert(reqs, { "/kangleipinfo", { method = ngx.HTTP_POST, args = "ip=" ..v.ip } })
		
		--[[
	    local hc = http:new()
        local ok, code, headers, status, body  = hc:request {
            --url = "http://www.qunar.com/",
            --- proxy = "http://127.0.0.1:8888",
            --- timeout = 3000,
            --method = "POST", -- POST or GET
            -- add post content-type and cookie
            --headers = { Cookie = "ABCDEFG", ["Content-Type"] = "application/x-www-form-urlencoded" },
            --body = "uid=1234567890",
            url = "http://" .. v.ip .. ":59188/core.whm?whm_call=info",
            timeout = 3000,
	        user = config:get('kangleuser'),
	        password = config:get('kanglepass'),
        }

		if ok == nil then
			ngx.say(v.ip, "\ttimeout")
		else
			local doc = xml.eval(body)
			ngx.say(v.ip, "\t", doc:find("version")[1])		
		end
		]]--
	end
    local resps = { ngx.location.capture_multi(reqs) }
 
    -- loop over the responses table
    for i, r in ipairs(resps) do
        resp:writeln( r.body)
    end	
end

function vhstat(req, resp)
	
	resp.headers['Content-Type'] = 'application/json; charset=utf-8'
	resp.headers['Server'] = 'openresty+ycd'
	req:read_body()
    local hc = http:new()
    local ok, code, headers, status, body  = hc:request {
        url = "http://" .. req:get_arg('ip') .. ":59188/core.whm?whm_call=stat_vh&vh=" .. req:get_arg('vh') .."",
        timeout = 3000,
        user = config:get('kangleuser'),
        password = config:get('kanglepass'),
    }
	if not ok then
		resp:writeln(cjson.encode({status = false, info = code}))
	else
		doc = xml.eval(body)
		if not doc:find("name")  then
			result = {
				status = false,
				info = 'unknown vhost',
			}
		else
			result = {
				status = true,
				name = (doc:find("name") and doc:find("name")[1]) or '',
				connect = (doc:find("connect") and doc:find("connect")[1]) or 0,
				speed = (doc:find("speed") and doc:find("speed")[1]) or 0,
				worker = (doc:find("worker") and doc:find("worker")[1]) or 0,
			}
		end
		resp:writeln(cjson.encode(result))	
	end
	--resp:writeln(body)
end

function reload(req, resp) 
	resp.headers['Content-Type'] = 'text/html; charset=utf-8'
	req:read_body()
	if req.method == 'POST' then
		--[[
		resp:writeln(ngx.req.get_body_data())
		local  post_data = ngx.decode_args(ngx.req.get_body_data())
		for k,v in pairs(post_data) do
			if type(v) == 'table' then
				resp:writeln(k)
				for k1,v1 in pairs(v) do
					resp:writeln("" .. k1 .. '==>' .. v1)
				end
			else
			resp:writeln("" .. k .. '=>' .. v)
			end
		end
		]]--
		sock:settimeout(3000)
		local ips = req:get_arg('ip[]')
		if type(ips) ~= 'table' then
				local v = ips
				if not v then v = '8.8.8.8' end
			    local ok, err = sock:connect(v, 59188)
			    if not ok then
			    	ngx.say("failed to connect: ", err, v)

			    else

			    	local req = "GET /core.whm?whm_call=reload_vh HTTP/1.1\r\nHost: ".. v ..":59188\r\nConnection: keep-alive\r\nAuthorization: Basic YWRtaW46d2pjbm1jZG4=\r\n\r\n"

			    	local bytes, err = sock:send(req)
			    	if not bytes then
			    		ngx.say("failed to send request: ", err)
			    	else
			    		ngx.say("reload kangle ok:\t", v)
			    	end
			    end
		else
			for _, v in pairs(ips) do
			    local ok, err = sock:connect(v, 59188)
			    if not ok then
			    	ngx.say("failed to connect: ", err, v)

			    else

			    	local requ = "GET /core.whm?whm_call=reload_vh HTTP/1.1\r\nHost: ".. v ..":59188\r\nConnection: keep-alive\r\nAuthorization: Basic YWRtaW46d2pjbm1jZG4=\r\n\r\n"

			    	local bytes, err = sock:send(requ)
			    	if not bytes then
			    		ngx.say("failed to send request: ", err)
			    	else
			    		ngx.say("reload kangle ok:\t", v)
			    	end
			    end

			end 
		end
		--resp:writeln(req:get_arg('ip[]'))
	end


	local ip = mysql.Mysql:getServerIp()
	local content = {
		ip = ip,
	}
	resp:tpl(content, config:get('templatedir')..'/reload.html')
end
