require "resty.LuaXML"
require "cjson"
mysql = require "mysql"
config = ngx.shared.config --global variable

if not os.getenv("APPLICATION_ENV") and  os.getenv("APPLICATION_ENV") ~= "production" then
	configfile = "/home/lua/luaapi/config-dev.json"
	ngx.log(ngx.WARN, 'lua ycd config : ' .. configfile  .. ', if production, please run shell : "export APPLICATION_ENV=production"')
else
	configfile = "config.json"
end
local file = io.open(configfile, "r")
if not file then
	 error('config file not exists:"' .. configfile .. '"')
end
local content = cjson.decode(file:read("*all"))
file:close()

for name, value in pairs(content) do
    config:set(name, value)
end