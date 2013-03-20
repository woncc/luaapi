nginx.conf 

```
lua_package_path '/home/www/lua/?.lua;;';
server {
  listen 80;
  server_name example.no www.example.no;
  set $kangleuser 11111;
  set $kanglepass 11111;  
  set $root /home/www/;
  root $root;

  # Serve static if file exist, or send to lua
  location / { try_files $uri @lua; }
  # Lua app
  location @lua {
  	  resolver 114.114.114.114  valid=600s; #设置dns地址及缓存有效时间
  	  resolver_timeout 5s; #dns查询超时时间	
  	  lua_code_cache off;  
      content_by_lua_file $root/lua/index.lua;
  }
}  
```
