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

ycd.map("^/ajax/stats_s", "stats.s")
ycd.map("^/klajax/stats_s", "server.vhstat")
ycd.map("^/klajax/nameserver", "domain.nameserver")
ycd.map("^/klajax/domaincname", "domain.domaincname")

ycd.map("^/api/nginx/source$","nginx.source")

ycd.map("^/source/check$","source.check")

ycd.map("^/tools/zuhe$","tools.zuhe")

ycd.map("^/antiddos.yundun.cn/verify$","verify.check")
ycd.map("^/antiddos.yundun.cn/verifycode","verify.code")

ycd.setup()

