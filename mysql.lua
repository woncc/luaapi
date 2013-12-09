#!/usr/bin/env lua

module('mysql',package.seeall)
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
                host = config:get("monitor:dbhost"),
                port = 3306,
                database = config:get("monitor:dbname"),
                user = config:get("monitor:dbuser"),
                password = config:get("monitor:dbpass"),
                max_package_size = 1024
        }
        if not ok then
                ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
                return
        end

        db:query("set names utf8")
        return db
end

function Mysql:init(host, user, pass, name, port)
    db,err = mysql:new()
    if not db then
            ngx.log(ngx.WARN,"failed to instantiate mysql: ", err)
            return
    end

    db:set_timeout(1000)

    local ok,err,errno,sqlstate = db:connect{
            host = host,
            port = 3306,
            database = name,
            user = user,
            password = pass,
            max_package_size = 1024
    }
    if not ok then
            ngx.log(ngx.WARN,"failed to connect: ", err, ": ", errno, " ", sqlstate)
            return
    end

    db:query("set names utf8")
    return db
end

function Mysql:Q(sql)
    res,err,errno,sqlstate = db:query(sql)
    if not res then
            ngx.log(ngx.WARN, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
            return
    end
    return res
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

function Mysql:getServerIp()
    db,err = mysql:new()
    if not db then
            ngx.say("failed to instantiate mysql: ",err)
            return
    end

    db:set_timeout(1000)

    local ok,err,errno,sqlstate = db:connect{
            host = config:get("cp:dbhost"),
            port = 3306,
            database = config:get("cp:dbname"),
            user = config:get("cp:dbuser"),
            password = config:get("cp:dbpass"),
            max_package_size = 1024
    }
    if not ok then
            ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
            return
    end

    db:query("set names utf8")
    
    sql = "SELECT s.ip	FROM attribute a,server_ip s WHERE a.type = 'server' AND a.`use` & 4 AND a.pid = s.id AND s.pid = 0 order by s.id desc"
	res,err,errno,sqlstate = db:query(sql)
	if not res then
	        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
	        return
	end
	return res
end
