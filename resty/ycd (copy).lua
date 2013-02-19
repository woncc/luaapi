function loader()
--run mvc get the request then get controller to deal the request
--local dispatcher = require yagami/library/?/dispatcher.lua

local ret={
        method=ngx.var.request_method,
        schema=ngx.var.schema,
        host=ngx.var.host,
        hostname=ngx.var.hostname,
        uri=ngx.var.request_uri,
        path=ngx.var.uri,
        filename=ngx.var.request_filename,
        query_string=ngx.var.query_string,
        headers=ngx.req.get_headers(),
        user_agent=ngx.var.http_user_agent,
        remote_addr=ngx.var.remote_addr,
        remote_port=ngx.var.remote_port,
        remote_user=ngx.var.remote_user,
        remote_passwd=ngx.var.remote_passwd,
        content_type=ngx.var.content_type,
        content_length=ngx.var.content_length,
        uri_args=ngx.req.get_uri_args(),
        socket=ngx.req.socket
    }
 
  package.path = ngx.var.yagami_home .. '/library/?.lua;' ..ngx.var.yagami_home .. '/location/?.lua;' .. package.path
  --ngx.say(package.path)

local path = ngx.var.uri
local len = string.len(path)
local location = string.sub(path,2,len)
require(location)

end


--run loader init
--loader()



function ycd_boot()
    local ngx_ctx = ngx.ctx
    local uri         = ngx.var.REQUEST_URI
    local page_found  = false

    require(ngx.var.root .. "router.lua")
    -- match order by definition order
    for _, k in ipairs({}) do
        ngx.log(ngx.INFO, "DEBUG::::", k)
        local args = {string_match(uri, k)}

        if args and #args>0 then
            page_found = true
            ngx_ctx.request  = requ
            ngx_ctx.response = resp

            if type(v) == "function" then                
                local ok, ret = pcall(v, requ, resp, unpack(args))
                if not ok then resp:error(ret) end
                resp:finish()
                resp:do_defers()
                resp:do_last_func()
            elseif type(v) == "table" then
                v:_handler(requ, resp, unpack(args))
            else
                ngx.exit(500)
            end
            break
        end
    end

    if not page_found then
        ngx.exit(404)
    end
end

----------
ycd_boot()
----------
