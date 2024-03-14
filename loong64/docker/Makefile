include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/moby/moby
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

# v25.0.4
TAG ?= v25.0.5

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build: build_src/$(SOURCE)
	docker run --rm -e GOARCH=$(GOARCH) \
		-e  VERSION=$(patsubst v%,%,$(TAG)) \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(GO_IMG) ./hack/make.sh binary-daemon binary-proxy
