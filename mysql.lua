#!/usr/bin/env lua

module('mysql',package.seeall)
local JSON = require("cjson")
local mysql = require "resty.mysql"
local db = nil
Mysql={}

function Mysql:new()
        db,err = mysql:new()
        if not db then
                ngx.say("failed to instantiate mysql: ",err)
                return
        end

        db:set_timeout(1000)

        local ok,err,errno,sqlstate = db:connect{
                host = "127.0.0.1",
                port = 3306,
                database = "yundun_monitor",
                user = "root",
                password = "yd-db-2012",
                max_package_size = 1024
        }
        if not ok then
                ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
                return
        end

        db:query("set names utf8")
        return db
end


function Mysql:query(sql)
    Mysql:new()
    res,err,errno,sqlstate = db:query(sql)
    if not res then
            ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
    end
    return res
end
