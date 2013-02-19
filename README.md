nginx.conf 

```
lua_package_path '/home/www/lua/?.lua;;';
server {
  listen 80;
  server_name example.no www.example.no;
  set $root /home/www/;
  root $root;

  # Serve static if file exist, or send to lua
  location / { try_files $uri @lua; }
  # Lua app
  location @lua {
      content_by_lua_file $root/lua/index.lua;
  }
}  
```
