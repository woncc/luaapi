module("clearcache",package.seeall)
local mysql = require "mysql"
local beanstalkd = require 'resty.beanstalkd'
local sock = ngx.socket.tcp()
function clear(req, resp)
--while true do
if req.uri_args['url'] == nil then
	resp:writeln("no url?")
else
	clearCache(req.uri_args['url'])
end

 -- os.execute("sleep 3")
--end
end

function main() 
    -- new and connect
    local bean, err = beanstalkd:new()
    if not bean then
        ngx.say("failed to init beanstalkd:", err)
        return
    end
    --ngx.say("initialized ok")

    local ok, err = bean:connect('192.168.3.104', '11300')
    if not ok then
        ngx.say("failed to connect beanstalkd:", err)
        return
    end
    --ngx.say("connect ok")	
    -- watch tube

    local ok, err = bean:use("cleancache")

    local id, data = bean:peekready()   
    if not id then
    	ngx.say("no queue in cleancache")
    	return
    end
    local nfindex = string.find(data, "\t")
    local cmd = string.sub(data, 0, nfindex) 
    local url = string.sub(data, nfindex+1)
    clearCache(url)
    bean:delete(id)
    --ngx.say("reserve hello ok, id:", id, "data:", data)

end

function clearCache(url) 
	ips = mysql.Mysql:getServerIp()
	sock:settimeout(3000)

	for _, v in pairs(ips) do
	    --ngx.say(v.ip)
	    local ok, err = sock:connect(v.ip, 59188)
	    if not ok then
	    	ngx.say("failed to connect: ", err, v.ip)

	    else

	    	local req = "GET /core.whm?whm_call=clean_cache&url=".. url .." HTTP/1.1\r\nHost: ".. v.ip ..":59188\r\nConnection: keep-alive\r\nAuthorization: Basic YWRtaW46d2pjbm1jZG4=\r\n\r\n"

	    	local bytes, err = sock:send(req)
	    	if not bytes then
	    		ngx.say("failed to send request: ", err)
	    	else
	    		ngx.say("clear cache url:\t ", url, "\tin host:\t", v.ip)
	    	end
	    end

	end 		        


end
