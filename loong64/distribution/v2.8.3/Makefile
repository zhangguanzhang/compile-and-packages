include ../../../lib.Makefile
include ../../lib.Makefile

SOURCE_URL=https://github.com/distribution/distribution.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v2.8.3

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	cd $@ && \
		git apply ../../0001-support-loong64.patch

source: build_src/$(SOURCE)

build-ABI2.0:
	cd build_src/$(SOURCE)/ && \
		docker build . -f Dockerfile.build -t registry:$(TAG)-loong64 \
		--build-arg GO_IMG=m.daocloud.io/docker.io/library/golang:1.25-trixie  \
		--build-arg=ALPINE=lcr.loongnix.cn/library/alpine:3

build-ABI1.0:
	cd build_src/$(SOURCE)/ && \
		DOCKER_BUILDKIT=1  docker bake --load -f docker-bake.hcl  \
			--set image-all.platform=linux/loong64 \
			--set image-all.tags=registry:$(TAG)-loong64 \
			--set 'image-all.args.GO_IMG=cr.loongnix.cn/library/golang:1.25-buster'  \
			--set 'image-all.args.ALPINE=cr.loongnix.cn/library/alpine:3.11'  image-all

image: source build-ABI$(ABI)
