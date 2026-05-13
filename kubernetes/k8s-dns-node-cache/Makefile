include ../../lib.Makefile

SOURCE_URL=https://github.com/kubernetes/dns.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= 1.26.5
IMAGE_REPO ?= registry.aliyuncs.com/zhangguanzhang
IMAGE ?= $(IMAGE_REPO)/k8s-dns-node-cache:$(patsubst v%,%,$(TAG))
IMAGE_ARCH ?= amd64 arm64

BUILD_IMAGE ?= m.daocloud.io/docker.io/library/golang:1.23.12-bookworm
IPTIMAGE ?= registry.k8s.io/build-image/distroless-iptables:v0.6.13

EXTR_ARGS = IPTIMAGE=$(IPTIMAGE) BUILD_IMAGE=$(BUILD_IMAGE)

default: image

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

image: source
	for arch in $(IMAGE_ARCH); do \
		 make -C build_src/$(SOURCE) containers CONTAINER_BINARIES=node-cache DOCKER_BUILD_FLAGS=--load $(EXTR_ARGS) VERSION=$(TAG) ARCH=$${arch}; \
	done
