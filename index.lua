local ycd = require "resty.ycd"

ycd.map("^/api/agent$","task.agent")
ycd.map("^/api/web$","api.web")
ycd.map("^/api/ping$","api.ping")
ycd.map("^/api/web$","api.web")
ycd.map("^/api/cpu$","api.cpu")
ycd.map("^/api/mem$","api.mem")
ycd.map("^/api/disk$","api.disk")
ycd.map("^/api/flow$","api.flow")
ycd.map("^/api/clearcache$","clearcache.cleanurl")
ycd.map("^/api/clearcache/cleaner$","clearcache.cleaner")
ycd.map("^/kangleip$","server.ips")
ycd.map("^/kangleinfo$","server.info")
ycd.map("^/kangleipinfo$","server.ipinfo")

ycd.map("^/kanglereload$","server.reload")

ycd.map("^/ajax/vhstat", "server.vhstat")
ycd.map("^/ajax/domainrecord", "domain.record")

ycd.setup()

