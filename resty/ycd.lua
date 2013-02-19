module("resty.ycd", package.seeall)


_VERSION = '0.01'

local string_match = string.match
local  route_insert = table.insert
local route_table = {}
--
function _global_init()
    local global={}
    
    local function _set(g,k,v)
        if not global[g] then
            global[g]={}
        end
        global[g][k]=v
        return v
    end
    
    local function _get(g, k)
        if not global[g] then
            global[g]={}
        end
        return global[g][k]
    end

    local function _vars(g)
        if not global[g] then
            global[g]={}
        end
        return global[g]
    end
   
    return _set, _get, _vars
end

set, get, vars = _global_init()

function map(uri, func_name)
    route_table[uri] = func_name
end

function setup()
    local ngx_var = ngx.var
    local ngx_req = ngx.req    
    local requ = {
        method          = ngx_var.request_method,
        schema          = ngx_var.schema,
        host            = ngx_var.host,
        hostname        = ngx_var.hostname,
        uri             = ngx_var.request_uri,
        path            = ngx_var.uri,
        filename        = ngx_var.request_filename,
        query_string    = ngx_var.query_string,
        headers         = ngx_req.get_headers(),
        user_agent      = ngx_var.http_user_agent,
        remote_addr     = ngx_var.remote_addr,
        remote_port     = ngx_var.remote_port,
        remote_user     = ngx_var.remote_user,
        remote_passwd   = ngx_var.remote_passwd,
        content_type    = ngx_var.content_type,
        content_length  = ngx_var.content_length,
        uri_args        = ngx_req.get_uri_args(),
        socket          = ngx_req.socket
    }
     local response = require "resty.ycd.response"
     local resp = response.Response:new()

    --ngx.log(ngx.INFO, "cjson:", cjson.encode(route_table))
    for   uri, func_name in pairs(route_table) do
        local mod_name, fn = string_match(func_name, '^(.+)%.([^.]+)$')
        local match = ngx.re.match(ngx.var.uri, uri, "") -- regex mather in compile mode
        if match then
            --ngx.log(ngx.INFO, "URI:", mod_name)
            mod = require(mod_name)
            local func = mod[fn]
            if func then              
                local ok, ret = pcall(func, requ, resp)
                if not ok then resp:error(ret) end
                resp:finish()          
            else
                local error_info = "MOOCHINE URL Mapping Error:[" .. uri .. "=>" .. func_name .. "] function or controller not found in module: " .. mod_name

                ngx.log(ngx.ERR, error_info)                
            end         
            --exit = view(match) or ngx.HTTP_OK
            ngx.exit( ngx.HTTP_OK )
        end
    end
    -- no match, return 404
    ngx.exit( ngx.HTTP_NOT_FOUND )
end


