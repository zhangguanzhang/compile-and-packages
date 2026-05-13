include ../../lib.Makefile

SOURCE_URL=https://github.com/coredns/coredns.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.12.0
IMAGE_REPO ?= registry.aliyuncs.com/zhangguanzhang
IMAGE ?= $(IMAGE_REPO)/coredns:$(patsubst v%,%,$(TAG))
IMAGE_ARCH ?= amd64 arm64
GOLANG_VERSION ?= $(shell go version | awk '{gsub("go", "",$$3);print $$3}')

default: image

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

image: source
	for arch in $(IMAGE_ARCH); do \
		 mkdir -p build_src/$(SOURCE)/build/docker/$${arch}; \
		 make -C build_src/$(SOURCE) coredns GOLANG_VERSION=$(GOLANG_VERSION) BINARY=build/docker/$${arch}/coredns GOARCH=$${arch}; \
		 make -C build_src/$(SOURCE) -f Makefile.docker docker-build DOCKER=coredns LINUX_ARCH=$${arch} VERSION=$(TAG) EXTRA_DOCKER_BUILD_ARGS="--load --pull"; \
	done
