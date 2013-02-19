#!/usr/bin/env lua

module('resty.ycd.response',package.seeall)

local table_insert = table.insert
local table_concat = table.concat
local string_match = string.match

Response={}

function Response:new()
    local ret={
        headers=ngx.header,
        _cookies={},
        _output={},
        _defer={},
        _last_func=nil,
        _eof=false
    }
    setmetatable(ret,self)
    self.__index=self
    return ret
end



function Response:do_defers()
    if self._eof==true then
        for _, f in ipairs(self._defer) do
            local ok, err = pcall(f)
            if not ok then
                logger:error('Error while doing defers: %s', err)
            end
        end
    else
        ngx.log(ngx.ERR, "response is not finished")
    end
end

function Response:write(content)
    if self._eof==true then
        local error_info = "Moochine WARNING: The response has been explicitly finished before."
        logger:warn(error_info)
        ngx.log(ngx.ERR, error_info)
        return
    end

    table_insert(self._output,content)
end

function Response:writeln(content)
    if self._eof==true then
        local error_info = "Moochine WARNING: The response has been explicitly finished before."
        logger:warn(error_info)
        ngx.log(ngx.ERR, error_info)
        return
    end

    table_insert(self._output,content)
    table_insert(self._output,"\r\n")
end

function Response:redirect(url, status)
    ngx.redirect(url, status)
end

function Response:_set_cookie(key, value, encrypt, duration, path)
    if not value then return nil end
    
    if not key or key=="" or not value then
        return
    end

    if not duration or duration<=0 then
        duration=604800 -- 7 days, 7*24*60*60 seconds
    end

    if not path or path=="" then
        path = "/"
    end

    if value and value~="" and encrypt==true then
        value=ndk.set_var.set_encrypt_session(value)
        value=ndk.set_var.set_encode_base64(value)
    end

    local expiretime=ngx.time()+duration
    expiretime = ngx.cookie_time(expiretime)
    return table_concat({key, "=", value, "; expires=", expiretime, "; path=", path})
end

function Response:set_cookie(key, value, encrypt, duration, path)
    local cookie=self:_set_cookie(key, value, encrypt, duration, path)
    self._cookies[key]=cookie
    ngx.header["Set-Cookie"]=mch.functional.table_values(self._cookies)
end


function Response:error(info)
    local error_info = "Moochine ERROR: " .. info
    if self._eof==false then
        ngx.status=500
        self.headers['Content-Type'] = 'text/html; charset=utf-8'
        self:write(error_info)
    end
    logger:error(error_info)
    --ngx.log(ngx.ERR, error_info)
end

function Response:is_finished()
    return self._eof
end

function Response:finish()
    if self._eof==true then
        return
    end

    self._eof = true
    ngx.print(self._output)
    self._output = nil
    local ok, ret = pcall(ngx.eof)
    if not ok then
        ngx.log(ngx.ERR, "ngx.eof() error:", ret)
    end
end
