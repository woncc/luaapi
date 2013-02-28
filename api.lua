module("api",package.seeall)
local JSON = require "cjson"
local mysql = require "mysql"
function ping(req, resp)
    if req.method=='GET' then
        -- resp:writeln('Host: ' .. req.host)
        -- resp:writeln('Hello, ' .. ngx.unescape_uri(name))
        -- resp:writeln('name, ' .. req.uri_args['name'])
        resp:writeln('0')  
        elseif req.method=='POST' then
        --resp:writeln('POST to Host: ' .. req.remote_addr)
        req:read_body()
        sql = "INSERT INTO `stats_ping` (remote_ip, node_ip, info) VALUES ('".. req.remote_addr  .."', '".. req:get_arg("ip", '') .."', '".. req:get_arg("info", '') .."')"
         --resp:writeln(sql)
         if req:get_arg("ip") == nil or req:get_arg("info") == nil then 
            resp:writeln('0')
        else
            mysql.Mysql:query(sql)
            resp:writeln('1')
        end
    end 
end

-- view 80 port 
function web(req, resp)
    req:read_body()
    sql = "INSERT INTO `stats_web` (remote_ip, node_ip, info) VALUES ('".. req.remote_addr  .."', '".. req:get_arg("ip", '') .."', '".. req:get_arg("info", '') .."')"
     if req:get_arg("ip") == nil or req:get_arg("info") == nil then 
        resp:writeln('0')
    else
        mysql.Mysql:query(sql)
        resp:writeln('1')
    end    
end

-- cpu
function cpu(req, resp)
    req:read_body()
    sql = "INSERT INTO `stats_cpu` (remote_ip, node_ip, info) VALUES ('".. req.remote_addr  .."', '".. req:get_arg("ip", '') .."', '".. req:get_arg("info", '') .."')"
     if req:get_arg("ip") == nil or req:get_arg("info") == nil then 
        resp:writeln('0')
    else
        mysql.Mysql:query(sql)
        resp:writeln('1')
    end    
end

-- memory
function mem(req, resp)
    req:read_body()
    sql = "INSERT INTO `stats_mem` (remote_ip, node_ip, info) VALUES ('".. req.remote_addr  .."', '".. req:get_arg("ip", '') .."', '".. req:get_arg("info", '') .."')"
     if req:get_arg("ip") == nil or req:get_arg("info") == nil then 
        resp:writeln('0')
    else
        mysql.Mysql:query(sql)
        resp:writeln('1')
    end    
end

-- disk
function disk(req, resp)
    req:read_body()
    sql = "INSERT INTO `stats_disk` (remote_ip, node_ip, info) VALUES ('".. req.remote_addr  .."', '".. req:get_arg("ip", '') .."', '".. req:get_arg("info", '') .."')"
     if req:get_arg("ip") == nil or req:get_arg("info") == nil then 
        resp:writeln('0')
    else
        mysql.Mysql:query(sql)
        resp:writeln('1')
    end    
end

-- flow
function flow(req, resp)
    req:read_body()
    sql = "INSERT INTO `stats_flow` (remote_ip, node_ip, info) VALUES ('".. req.remote_addr  .."', '".. req:get_arg("ip", '') .."', '".. req:get_arg("info", '') .."')"
     if req:get_arg("ip") == nil or req:get_arg("info") == nil then 
        resp:writeln('0')
    else
        mysql.Mysql:query(sql)
        resp:writeln('1')
    end    
end
