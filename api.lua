module("api",package.seeall)

local JSON = require("cjson")
local mysql = require "mysql"
function hello(req, resp, name)
    if req.method=='GET' then
        -- resp:writeln('Host: ' .. req.host)
        -- resp:writeln('Hello, ' .. ngx.unescape_uri(name))
        -- resp:writeln('name, ' .. req.uri_args['name'])
         resp.headers['Content-Type'] = 'application/json'
        ff = mysql.Mysql:query("select id,username,age from users where id=2")
        ngx.print(ff)  
    elseif req.method=='POST' then
        -- resp:writeln('POST to Host: ' .. req.host)
        req:read_body()
        resp.headers['Content-Type'] = 'application/json'
        resp:writeln(JSON.encode(req.post_args))
    end 
end



