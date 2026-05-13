DOCKER_CONFIG ?= $(HOME)/.docker/config.json
GO_VERSION ?= latest
GO_IMG ?= m.daocloud.io/docker.io/library/golang:$(GO_VERSION)
WEB_IMG ?= registry.aliyuncs.com/zhangguanzhang/ran
CONTAINER_RUNTIME ?= docker
IMG_REPO ?= zhangguanzhang

HOST_ARCH ?= $(shell uname -m | tr A-Z a-z)
ifeq ($(HOST_ARCH),x86_64)
	HOST_ARCH=amd64
endif
ifeq ($(HOST_ARCH),aarch64)
	HOST_ARCH=arm64
endif
ifeq ($(HOST_ARCH),armv7l)
    HOST_ARCH=armv7
endif
ifeq ($(HOST_ARCH),loongarch64)
    HOST_ARCH=loong64
endif

DOCKER0_IP ?= $(shell ip -4 addr show docker0 | awk -F '[ /]+' '/inet/{print $$3;exit}')

