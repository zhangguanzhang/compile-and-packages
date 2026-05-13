include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/krallin/tini
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v0.19.0

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build-ABI2.0:
	docker run --rm -e GOARCH=$(GOARCH) \
		-e CC=loongarch64-linux-gnu-gcc \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(CC_IMG) \
		bash -c 'cmake . && make tini-static'
build-ABI1.0:
	docker run --rm -e GOARCH=$(GOARCH) \
		-e CC=loongarch64-linux-gnu-gcc \
		-e PATH=/loongson-gnu-toolchain/bin:$$PATH \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(CC_IMG) \
		bash -c 'cmake . && make tini-static'

build: build_src/$(SOURCE) build-ABI$(ABI)
	mv build_src/tini/tini-static docker-init
