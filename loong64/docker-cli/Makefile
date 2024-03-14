include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/docker/cli
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
		-v `pwd`/build_src/$(SOURCE):/go/src/github.com/docker/cli -w /go/src/github.com/docker/cli $(GO_IMG) make binary
