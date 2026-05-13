include ../lib.Makefile

SOURCE_URL=https://github.com/tailscale/tailscale.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.76.6
IMAGE_REPO ?= registry.aliyuncs.com/zhangguanzhang
DERP_IMAGE ?= $(IMAGE_REPO)/derper:$(TAG)-loong64
IMAGE ?= $(IMAGE_REPO)/tailscale:$(TAG)-loong64
IMAGE_ARCH ?= linux/amd64,linux/arm64
# 要和 go.mod 里版本一致
GO_IMG := registry.aliyuncs.com/zhangguanzhang/loong64:go1.23

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

derp: source
	docker  build --build-arg GO_IMG=$(GO_IMG) . -t $(DERP_IMAGE) --push

tailscale: source
	docker build --build-arg GO_IMG=$(GO_IMG) --build-arg BASE_IMG=$(ALPINE_IMG) build_src/$(SOURCE) -t $(IMAGE)

image: derp tailscale
