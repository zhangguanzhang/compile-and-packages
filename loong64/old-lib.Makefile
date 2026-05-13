GO_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.22
CC_GO_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.21-cc
CC_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:cc
GO_IMG_ALPINE ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.21-alpine
GOARCH ?= loong64
ALPINE_IMG ?= cr.loongnix.cn/library/alpine:3.11

clean:
	rm -rf build_src
