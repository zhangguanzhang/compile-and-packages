include ../lib.Makefile

SOURCE_URL=https://github.com/tailscale/tailscale.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.70.0
IMAGE_REPO ?= registry.aliyuncs.com/zhangguanzhang
DERP_IMAGE ?= $(IMAGE_REPO)/derper:$(TAG)
IMAGE ?= $(IMAGE_REPO)/tailscale:$(TAG)
IMAGE_ARCH ?= linux/amd64,linux/arm64

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

derp: source
	docker buildx build --platform=$(IMAGE_ARCH) . -t $(DERP_IMAGE) --push

image: derp
	docker buildx build --platform=$(IMAGE_ARCH) build_src/$(SOURCE) -t $(IMAGE) --push
