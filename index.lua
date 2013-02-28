local ycd = require "resty.ycd"

ycd.map("^/api/agent$","task.agent")
ycd.map("^/api/web$","api.web")
ycd.map("^/api/ping$","api.ping")
ycd.map("^/api/web$","api.web")
ycd.map("^/api/cpu$","api.cpu")
ycd.map("^/api/mem$","api.mem")
ycd.map("^/api/disk$","api.disk")
ycd.map("^/api/flow$","api.flow")
ycd.map("^/api/clearcache$","clearcache.clear")
ycd.map("^/api/clearcache/main$","clearcache.main")

ycd.setup()

