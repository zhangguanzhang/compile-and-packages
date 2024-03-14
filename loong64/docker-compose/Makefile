include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/docker/compose
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

# v2.24.7
TAG ?= v2.25.0

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	cd $@ && \
		git apply ../../$(TAG)/*.patch

build: build_src/$(SOURCE)
	cd build_src/$(SOURCE) && \
		docker buildx bake --set binary.args.GO_IMG=$(GO_IMG_ALPINE) --set binary.args.GOARCH=$(GOARCH) binary && \
		mv bin/build/docker-compose ../../
