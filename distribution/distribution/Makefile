include ../../lib.Makefile

SOURCE_URL=https://github.com/distribution/distribution.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v2.8.3
IMAGE_ARCH ?= amd64 arm64
GOLANG_VERSION ?= $(shell go version | awk '{gsub("go", "",$$3);print $$3}')
ALPINE_VER ?= latest

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

clean:
	rm -rf build_src/$(SOURCE)

image: source
	cd build_src/$(SOURCE)/ && for arch in $(IMAGE_ARCH); do \
		DOCKER_BUILDKIT=1  docker bake --load -f docker-bake.hcl  \
			--set image-all.platform=linux/$${arch} \
			--set image-all.tags=registry:$(TAG)-$${arch} \
			--set 'image-all.args.GO_VERSION=1.24'  \
			--set 'image-all.args.ALPINE_VERSION=3.22'  image-all; \
	done
