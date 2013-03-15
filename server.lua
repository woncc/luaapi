module("server",package.seeall)
local http = require "resty.http"
local mysql = require "mysql"
local xml = require("resty.xmlSimple").newParser()

function ips() 
	ips = mysql.Mysql:getServerIp()

	for _, v in pairs(ips) do
	    ngx.say(v.ip)
	end 		        

end

function info()
	ips = mysql.Mysql:getServerIp()
	--[[ips = {}二维数组
	ips[1] = {}
	ips[1]["ip"] = "45.238.236.226"]]--
	for _, v in pairs(ips) do
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
            user = "admin",
            password = "111111",
        }

		if ok == nil then
			ngx.say(v.ip, "\ttimeout")
		else
			local x = xml:ParseXmlText(body)
			ngx.say(v.ip, "\t", x.info.result.version:value())		
		end

	end
end


