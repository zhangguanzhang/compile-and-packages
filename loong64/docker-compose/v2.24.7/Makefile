include ../../../lib.Makefile
include ../../lib.Makefile

SOURCE_URL=https://github.com/docker/compose
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

# v2.24.7
TAG ?= v2.40.3

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	cd $@ && \
	git apply ../../*.patch;

build: build_src/$(SOURCE)
	cd build_src/$(SOURCE) && \
		docker run --rm -v `pwd`:/v -w /v -e CGO_ENABLED=0 -e GOARCH=$(GOARCH) $(GO_IMG) make build || \ || \
		docker buildx bake --set binary.args.GOARCH=$(GOARCH) binary && \
		mv bin/build/docker-compose ../../
	tar zcf docker-compose-$(TAG).tar.gz docker-compose
