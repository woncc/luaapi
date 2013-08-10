module("nginx",package.seeall)
local mysql = require "mysql"
local beanstalkd = require 'resty.beanstalkd'
local sock = ngx.socket.tcp()
local string_find, string_sub, string_format = string.find, string.sub, string.format
local table_concat, table_insert = table.concat, table.insert

function source(req, resp) 
    -- new and connect
    local bean, err = beanstalkd:new()
    if not bean then
        ngx.say("failed to init beanstalkd:", err)
        return
    end
    --ngx.say("initialized ok")

    local ok, err = bean:connect(config:get("beanstalkd:host"), '11300')
    if not ok then
        ngx.say("failed to connect beanstalkd:", err)
        return
    end
    --ngx.say("connect ok")	
    -- watch tube

    local ok, err = bean:use("nginxsource")

    local id, data = bean:peekready()   
    if not id then
    	ngx.say("no queue in nginxsource")
    	return
    end
    local nfindex =split_by_char(data, "\t")

    bean:delete(id)
    if nfindex[1] == "add" then addSource(nfindex[2], nfindex[3], nfindex[4]) end
    if nfindex[1] == "del" then delSource(nfindex[2]) end

    ngx.say("reserve hello ok, id:", id, "data:", data)

end

function trim1(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--获取别名，如果host为空，则已前面最后一个为准
function getAlias(control_id, default_host)
	local result = {}
	local res = mysql.Mysql:Q("SELECT * FROM `member_domain_alias` WHERE domain_id='" .. control_id  .. "' and status=1")
	if res then 
		for key,val in pairs(res) do
    		local server_name = string.gsub(val.domain, ":%d+", "") --替换掉端口
    		server_name = string.gsub(server_name, "@%.", "")
    		local proxy_pass = string.gsub(val.host, ":0", "")
    		if not proxy_pass  or trim1(proxy_pass) == "" then proxy_pass = default_host end
    		if proxy_pass ~= nil then
    		if not result[proxy_pass] then result[proxy_pass] = {} end
    		if in_table(result[proxy_pass], server_name) ~= true then
    			table_insert(result[proxy_pass], server_name)
    		end		
    		end
		end
	end
	return result
end

--获取控制台id
function getControlId(domain_id, domain_type)
	local result = 0
    mysql.Mysql:init(config:get("cp:dbhost"), config:get("cp:dbuser"), config:get("cp:dbpass"), config:get("cp:dbname"))
    local res = mysql.Mysql:Q("SELECT id FROM `domain` WHERE domain_id='" .. domain_id .. "' and type='" .. domain_type .. "'")
    if res then
  		result = tonumber(res[1].id)
  	end
  	return result
end

function addSource(domain, domain_id, domain_type)
	local vhost = {} 
	local key,val,res = nil
	local listen = config:get("nginx:proxy_port") or 8081
    mysql.Mysql:init(config:get("cp:dbhost"), config:get("cp:dbuser"), config:get("cp:dbpass"), config:get("cp:dbname"))
    if domain_type == "cname" then
    	res = mysql.Mysql:Q("SELECT domain,GROUP_CONCAT(`host`) source FROM `member_domain_cname` WHERE parent_id='" .. domain_id  .. "' and balance_group_id=0 and `view`<>'searchengine' GROUP BY `domain`")
    else
    	res = mysql.Mysql:Q("SELECT * FROM `member_domain_ns_record` WHERE domain_id='" .. domain_id  .. "' and balance_group_id=0 and status=1")
    end
    local proxy_str = ""
    if res and domain_type == "ns" then
    	for key, val in pairs(res) do
    		local upstream_name = "up_" .. string.gsub(domain, "%.", "") .. "_" .. key
    		local server_name = val.name .. "." .. domain
    		server_name = string.gsub(server_name, "@%.", "")
    		proxy_str = proxy_str .. "upstream " .. upstream_name .. " {\n"
    		local sbc = split_by_char(val.value, "|")
    		for _,val in pairs(sbc) do
    			if val ~= "" then
    				proxy_str = proxy_str .. "\tserver " .. val .. "  max_fails=3  fail_timeout=60s;\n"
    			end
    		end
    		proxy_str = proxy_str .. "}\nserver {\n\tlisten  " .. listen .. ";\n\tserver_name    " .. server_name .. ";\n\tlocation / {\n\t\tproxy_pass    http://" .. upstream_name .. ";\n\t}\n}\n"
    	end
    		ngx.say(server_name)  	
    end
    if res and domain_type == "cname" then
    	for key, val in pairs(res) do
	    	local upstream_name = "up_" .. string.gsub(domain, "%.", "") .. "_" .. key
    		local server_name = string.gsub(val.domain, ":%d+", "")
    		server_name = string.gsub(server_name, "@%.", "")
    		proxy_str = proxy_str .. "upstream " .. upstream_name .. " {\n"
    		local sbc = split_by_char(val.source, ",")
    		for _,val in pairs(sbc) do
    			if val ~= "" then
    				local proxy_pass = string.gsub(val, ":0", "")
    				proxy_str = proxy_str .. "\tserver " .. proxy_pass .. "  max_fails=3  fail_timeout=60s;\n"
    			end
    		end
    		proxy_str = proxy_str .. "}\nserver {\n\tlisten  " .. listen .. ";\n\tserver_name    " .. server_name .. ";\n\tlocation / {\n\t\tproxy_pass    http://" .. upstream_name .. ";\n\t}\n}\n"
    		ngx.say(server_name)  	
    	end
    end
	local control_id = getControlId(domain_id, domain_type)
	local alias_server = getAlias(control_id, proxy_pass)
	for key,val in pairs(alias_server) do
		proxy_str = proxy_str  .. "server {\n\tlisten  " .. listen .. ";\n\tserver_name    " .. table.concat(val,  " ") .. ";\n\tlocation / {\n\t\tproxy_pass    http://" .. key .. ";\n\t}\n}\n"
		
	end
	local proxy_file = config:get("nginx:vhost_dir") .. "/" .. domain .. ".conf"
	local file,err = io.open(proxy_file, "w") 
	if file and proxy_str ~= "" then 
		file:write(proxy_str) 
		file:close()
	else
		ngx.say(err)
	end   	
	
	ngx.say(proxy_file)
	ngx.say(cjson.encode(alias_server))

	
end

function in_table ( t , e )
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end

function delSource(domain) 
	local proxy_file = config:get("nginx:vhost_dir") .. "/" .. domain .. ".conf"
	os.remove(proxy_file)
end

function split_by_char(str, div)
  local result = false
  if div ~= "" then
    local pos = 0
    result = {}

    if str ~= "" then
      -- for each divider found
      for st, sp in function() return string_find(str, div, pos, true) end do
        -- Attach chars left of current divider
        table_insert(result, string_sub(str, pos, st - 1))
        pos = sp + 1 -- Jump past current divider
      end
      -- Attach chars right of last divider
      table_insert(result, string_sub(str, pos))
    end
  end
  return result
end
