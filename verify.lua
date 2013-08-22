module("verify",package.seeall)
local memcached = require "resty.memcached"

function check(req, resp) 
	resp.headers['Content-Type'] = 'application/json; charset=utf-8'
 	resp.headers['Cache-Control'] = 'no-cache'
   	resp.headers['Pragma'] = 'No-Cache'	
	resp.headers['Date'] = "Thu, 22 Aug 1997 11:15:22 GMT"	
	req:read_body()
	local result = {["status"] = 0, ["info"] = "未知错误", ["code"] = 0}
	if req.method == 'POST' then
		local memcache, err = memcached:new()
		if not memcache then
		    result = {["status"] = 0, ["info"] = "未知错误", ["code"] = -1}
		end
		memcached:set_timeout(1000)
		local ok, err = memcache:connect(config:get("memcached:host"), 11211) 
		if not ok then
		    result = {["status"] = 0, ["info"] = "未知错误", ["code"] = -2}
		end   	
		local code = req:get_arg('code') or ''
		local setkey = ngx.md5(ngx.req.get_headers()["Host"] .. ngx.req.get_headers()["User-Agent"])
		local codekey,flag,err = memcache:get(setkey)
		if not codekey then
		    result = {["status"] = 0, ["info"] = "未知错误", ["code"] = -3}
		end
		local data,flag,err = memcache:get(codekey)
		if not data then
		    result = {["status"] = 0, ["info"] = "未知错误", ["code"] = -4}
		end	
		if data == code then
            --expires = ngx.cookie_time(4523969511)
            ngx.header["Set-Cookie"] = {"bdshare_id="..setkey.."; path=/"};-- expires=" .. expires .. ";
			result = {["status"] = 1, ["info"] = "验证正确"}
		else
			result = {["status"] = 0, ["info"] = "输入验证码有误，请重新输入。"}
		end
    end
	resp:write(cjson.encode(result))

end

function code(req, resp) 
	resp.headers['Content-Type'] = 'image/png'
 	resp.headers['Cache-Control'] = 'no-cache'
   	resp.headers['Pragma'] = 'No-Cache'
 	local memcache, err = memcached:new()
    if not memcache then
        ngx.say("failed to init memcached:", err)
        return
    end
	memcached:set_timeout(1000)
    local ok, err = memcache:connect(config:get("memcached:host"), 11211) 
    if not ok then
        ngx.say("failed to connect memcached:", err)
        return
    end    
    local key = math.random(1000)
    
    local pngkey = 'yzm-' .. key .. '-'
    local data,flag,err = memcache:get(pngkey)
    if not data then
        ngx.say("failed to get memcached:", err)
        return
    end
    --存入session
    local setkey = ngx.md5(ngx.req.get_headers()["Host"] .. ngx.req.get_headers()["User-Agent"])
    local ok,err = memcache:set(setkey, pngkey..'1', 3600)
    if not data then
        ngx.say("failed to get memcached:", err)
        return
    end
    ngx.say(data)
end
