module("server",package.seeall)
local mysql = require "mysql"

function ips() 
	ips = mysql.Mysql:getServerIp()

	for _, v in pairs(ips) do
	    ngx.say(v.ip)
	end 		        

end
