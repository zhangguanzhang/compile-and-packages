ABI ?= 2.0

GO_ABI1.0_IMG = registry.aliyuncs.com/zhangguanzhang/loong64:go1.25

ifeq ($(origin GO_IMG), command line)
else
  ifeq ($(ABI),1.0)
    GO_IMG := $(GO_ABI1.0_IMG)
  else
    GO_IMG := m.daocloud.io/docker.io/library/golang:1.25
  endif
endif

# CC_GO_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.25-cc

CC_IMG ?= registry.aliyuncs.com/zhangguanzhang/loong64:cc
# GO_IMG_ALPINE ?= registry.aliyuncs.com/zhangguanzhang/loong64:go1.21-alpine

GOARCH ?= loong64
ALPINE_IMG ?= cr.loongnix.cn/library/alpine:3.11

clean:
	rm -rf build_src
