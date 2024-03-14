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

build: build_src/$(SOURCE)
	docker run --rm -e GOARCH=$(GOARCH) \
		-e CC=loongarch64-linux-gnu-gcc \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(CC_IMG) \
		bash -c 'cmake . && make tini-static'
