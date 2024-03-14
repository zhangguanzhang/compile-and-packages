GO_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.21
CC_GO_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.21-cc
CC_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:cc
GO_IMG_ALPINE ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.21-alpine
GOARCH ?= loong64


clean:
	rm -rf build_src
