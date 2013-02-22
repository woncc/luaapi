module("task",package.seeall)
local JSON = require("cjson")
local mysql = require "mysql"
function agent(req, resp)
    local str = ''
    --resp.headers['Content-Type'] = 'text/html; charset=utf-8'
    if req.uri_args['s'] == nil then
        resp:writeln('error:no param')
    else
        res1 = mysql.Mysql:query("SELECT * FROM `agent` WHERE serial='" .. req.uri_args['s'] .. "'")
        for _, v1 in pairs(res1) do
            res2 = mysql.Mysql:query("SELECT * FROM `task_detail` WHERE task_id='" .. v1.task_id .. "'")

            for _, v2 in pairs(res2) do
                res3 = mysql.Mysql:query("SELECT * FROM `detail` WHERE id='" .. v2.detail_id .. "'")
                for _, v3 in pairs(res3) do
                    str =  str .. '#' .. v3.keyword .. '/' .. v2.frequency
                end 
            end  
            res4 = mysql.Mysql:query("SELECT * FROM `task_node` WHERE task_id='" .. v1.task_id .. "'")
            str = str .. '@@'
            for _, v4 in pairs(res4) do
                res5 = mysql.Mysql:query("SELECT * FROM `node` WHERE id='" .. v4.node_id .. "' AND status=1")
                for _, v5 in pairs(res5) do
                    str =  str .. '|' .. v5.ip
                end 
            end
            str = str .. "\n"            

        end        
        resp:write(str)
        --resp:writeln(JSON.encode(res2))
    end
end



