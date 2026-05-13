include ../../../lib.Makefile
include ../../lib.Makefile

SOURCE_URL=https://github.com/containerd/containerd
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.7.13

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	cd $@ && git apply ../../*.patch

build: build_src/$(SOURCE)
	docker run --rm -e GOARCH=$(GOARCH) \
		-v `pwd`/build_src/$(SOURCE):/v \
		-v `pwd`:/v/bin/ \
		-w /v $(GO_IMG) make STATIC=1 binaries
