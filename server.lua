module("server",package.seeall)
local http = require "resty.http"
--local xml = require("resty.LuaXML") --need put to init_by_lua,otherwise lua_code_cache on error

function ips() 
	local ip = mysql.Mysql:getServerIp()
	for _, v in pairs(ip) do
	    ngx.say(v.ip)
	end
end

function info()
	local ip = mysql.Mysql:getServerIp()
	--[[ips = {}二维数组
	ips[1] = {}
	ips[1]["ip"] = "45.238.236.226"]]--
	for _, v in pairs(ip) do
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


