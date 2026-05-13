include ../../../lib.Makefile
include ../../lib.Makefile

SOURCE_URL=https://github.com/loongson/qemu.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= 9.2-tcg-old
TARGET_LIST ?= loongarch64-linux-user,aarch64-linux-user,arm-linux-user
IMAGE ?= $(IMG_REPO)/qemu-user-static:$(firstword $(subst -, ,$(TAG)))-loong64

default: image

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@

build: build_src/$(SOURCE)
	$(CONTAINER_RUNTIME) run --rm -v `pwd`/:/opt -w /opt/ \
		-e CODE_DIR=build_src/$(SOURCE) \
		-e TARGET_LIST=$(TARGET_LIST) \
		m.daocloud.io/docker.io/library/ubuntu:22.04 bash build.sh

image: build
	$(CONTAINER_RUNTIME) build . -t $(IMAGE)

push:
	$(CONTAINER_RUNTIME) push $(IMAGE)
# 	rm -f qemu-*-static

test:
	$(CONTAINER_RUNTIME) run --rm --privileged $(IMAGE) --reset -p yes
	$(CONTAINER_RUNTIME) run --rm $(ALPINE_IMG) uname -m
	$(CONTAINER_RUNTIME) run --rm cr.loongnix.cn/loongson/loongnix-server:8.4 dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False tzdata
