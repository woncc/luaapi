local ycd = require "resty.ycd"

ycd.map("^/antiddos.yundun.cn/verify$","verify.check")
ycd.map("^/antiddos.yundun.cn/verifycode","verify.code")
ycd.setup()

