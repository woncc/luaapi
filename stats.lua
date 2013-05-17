module("stats",package.seeall)
local JSON = require("cjson")
local mysql = require "mysql"
function s(req, resp)
    local result = {}
    local res = {}
    local tablename = os.date("%Y_%m")
    local day = math.abs(os.date("%d"))

    resp.headers['Content-Type'] = 'application/json; charset=utf-8'
    
    mysql.Mysql:init("127.0.0.1", "admin", "BtnzbelyqYWv8tvRFYzy", "yundun_flow")
    res = mysql.Mysql:Q("SELECT sum(cache_bw) cache_bw FROM `" .. tablename .. "` WHERE day=" .. day  .. "")
    if not res then
    result['cache_bw'] = 0
    else 
  	result['cache_bw'] = tonumber(res[1].cache_bw) or 0
  	end
    
    mysql.Mysql:init("127.0.0.1", "admin", "BtnzbelyqYWv8tvRFYzy", "yundun_stat")
    res = mysql.Mysql:Q("SELECT sum(cc_hit)-sum(cc_pass) as cc_num  FROM `" .. tablename .. "` WHERE day=" .. day  .. "")
    if not res then
    	result['cc_num'] = 0
    else     
    	result['cc_num'] = tonumber(res[1].cc_num) or 0
    end
  	
  	
    resp:writeln(JSON.encode(result))
end



