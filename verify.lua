module("verify",package.seeall)
local memcached = require "resty.memcached"

function check(req, resp) 
	resp.headers['Content-Type'] = 'application/json; charset=utf-8'
 	resp.headers['Cache-Control'] = 'no-cache, must-revalidate,no-store'
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
		local data = 'hello,word!'
		if not codekey then
			data = '2v7x'
		    result = {["status"] = 0, ["info"] = "未知错误", ["code"] = -3}
		else
			data,flag,err = memcache:get(codekey)
			if not data then
				result = {["status"] = 0, ["info"] = "未知错误", ["code"] = -4}
			end	
		end
		if  data == code then
            --expires = ngx.cookie_time(4523969511)
            ngx.header["Set-Cookie"] = {"bdshare_id="..setkey.."; path=/"};-- expires=" .. expires .. ";
			result = {["status"] = 1, ["info"] = "验证正确"}
		else
			result = {["status"] = 0, ["info"] = "输入验证码有误，请重新输入。"}--, ["data"] = data, ["code"] = code}
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
        ngx.log(ngx.WARN, "failed to init memcached:", err)
    end
	memcached:set_timeout(1000)
    local ok, err = memcache:connect(config:get("memcached:host"), 11211) 
    if not ok then
        ngx.log(ngx.WARN,"failed to connect memcached:", err)
    end    
    local key = math.random(1000)
    
    local pngkey = 'yzm-' .. key .. '-'
    local data,flag,err = memcache:get(pngkey)
    if not data then
        ngx.log(ngx.WARN,"failed to get memcached:", err)
        data = ngx.decode_base64("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")
    end
    --存入session
    local setkey = ngx.md5(ngx.req.get_headers()["Host"] .. ngx.req.get_headers()["User-Agent"])
    local ok,err = memcache:set(setkey, pngkey..'1', 3600)
    if not data then
        ngx.log(ngx.WARN,"failed to set memcached:", err)
    end
    resp:write(data)
end
