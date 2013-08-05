module("domain",package.seeall)
local http = require "resty.http"
local whois = require "resty.whois"

function record(req, resp)
	
	resp.headers['Content-Type'] = 'application/json; charset=utf-8'
	resp.headers['Server'] = 'openresty+ycd'
	req:read_body()
  local domain = req:get_arg('domain') or ''
	--getRecordByAxfr('cb.vu')
	local results = getDomainByGoogle(domain)
	--local record = getDomainRecord('www.baidudfsfd.com', 'CNAME')
	--if not record then
		--resp:writeln("no record")
	--else
	--	resp:writeln(record)
	--end
	resp:write(cjson.encode(results))
end

function nameserver(req, resp)
	local wh, err = whois:new()
    if not wh then
        ngx.say("failed to init :", err)
        return
    end	
    wh:set_timeout(2000)
	local ok, err = wh:connect("whois.verisign-grs.com", "43")
    if not ok then
        ngx.say("failed to connect whois:", err)
        return
    end	
	local f,m = wh:nameserver('baidu.com')
	if not f then
		resp:write(m)
	end
	resp:write(cjson.encode(f))
end

--[[
get domain record
recordType : A|CNAME
]]--
function getDomainRecord( domain, recordType)
	local rtype = {
		A      = 1,
		NS     = 2,
		CNAME  = 5,
		PTR    = 12,
		MX     = 15,
		TXT    = 16,
		AAAA   = 28,
	}
    local resolver = require "resty.dns.resolver"
    local r, err = resolver:new{
        nameservers = {"8.8.8.8", {"8.8.4.4", 53} },
        retrans = 5,  -- 5 retransmissions on receive timeout
        timeout = 2000,  -- 2 sec
    }

    if not r then
        ngx.log(ngx.ERR, "failed to instantiate the resolver: ", err)
        return nil
    end

    local answers, err = r:query(domain)
    if not answers then
        ngx.log(ngx.ERR, "failed to query the DNS server: ", err)
        return nil
    end
    --ngx.log(ngx.DEBUG, "dns answers len:", #answers)
    local result = nil
    for i = 1, #answers do
        local ans = answers[i]
        ngx.log(ngx.DEBUG, ans.name, " ", ans.address or ans.cname, " type:", ans.type, " class:", ans.class, " ttl:", ans.ttl)
        if rtype[recordType] == ans.type then
        	result = ans.address or ans.cname
        end
        --ngx.say(ans.name, " ", ans.address or ans.cname,
        --        " type:", ans.type, " class:", ans.class,
        --        " ttl:", ans.ttl)
    end
    return result
end

function getDomainByGoogle( domain )
    local hc = http:new()
    local ok, code, headers, status, body  = hc:request {
        url = "http://ajax.googleapis.com/ajax/services/search/web?start=0&rsz=large&v=1.0&q=site:" .. domain,
        timeout = 3000,
    }

	if ok == nil then
		return {}
	else
		local content = cjson.decode(body)
		local  subdomain = {'@', 'www', 'bbs', 'vip', 'news'}
		if content.responseStatus == 200 then
			for i=1, #content.responseData.results do
				local res = content.responseData.results[i]
        local vs = string.sub(res.visibleUrl,1, -string.len(domain) - 2)
				if table_search(vs, subdomain) == nil then
					table.insert(subdomain, vs) --insert subdomain to table
				end
			end
			local  result = {status = false, data = {}}
      local  j = 1
			for i=1, #subdomain do
				local  sd = subdomain[i] .. '.' .. domain
        if i == 1 then sd = domain end
				ngx.log(ngx.DEBUG, sd, string.len(sd))
				local  ip = getDomainRecord(sd, 'A')
				if ip  then
         
				  result.data[j] = {subdomain = subdomain[i], ip = ip, domain = domain}
          j = j+1
				end
			end
      if #result.data then result.status = true end
			return result
		end
	end
end

--from http://www.ebanyu.com.ar
function getRecordByAxfr( domain )
    list=exec("dig NS "..domain.." +short")
    dns=explode(" ",list)
    fortn={}
    for i,v in ipairs(dns) do
	axfr=exec("dig @"..v.." "..domain.." axfr | sed 's/;; connection timed out.*/timeout/g;s/; Transfer.*/failed/g;s/^;.*//g;/^$/d;s/$/\\;/g'")
	if string.find(axfr,"failed")==nill and string.find(axfr,"timeout")==nil then
		tmp=explode(";",axfr)
		print("**********"..domain.."*********\n")
		for i,v in ipairs(tmp) do fortn[i]=v;ngx.say(v) end
		return(fortn)
 	else  print("Transfer with "..v.." failed.\n") end
    end
end

--Obtiene la salida de la ejecucion de un comando por consola.
--Get the output of the of the execution by console.
function exec(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- credit: http://richard.warburton.it
-- Similar a la función de php, divide un string por un delimitador y crea una array con estos.
-- Like the php function, splits a string by a delimiter and creates an array with them.
function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
  table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
  pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
 end
                       

--Cuenta los items de una tabla.
--Count the items in a table.
function count(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

--Busca y retorna el indice de una table segun el valor dado.
--Search and return the key from a table according to the value given.
function table_search(value,table)
  for i,v in pairs(table) do if v==value then return i end end
  return nil
end

