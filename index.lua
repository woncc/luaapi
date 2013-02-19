local ycd = require "resty.ycd"

ycd.map("^/hhhhh$","api.hello")
ycd.map("^/api/(.*)/(.*)$","api.hello")

ycd.setup()

