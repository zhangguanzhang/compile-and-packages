include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/Mirantis/cri-dockerd
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

# v0.3.10 v0.3.11
TAG ?= v0.3.12
TAG_VER = $(patsubst v%,%,$(TAG))

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build: build_src/$(SOURCE)
	docker run --rm -e GOARCH=$(GOARCH) \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(GO_IMG) make ARCH=$(GOARCH) static-linux
	mv build_src/$(SOURCE)/packaging/static/build/linux/cri-dockerd-$(TAG_VER).*.tgz cri-dockerd-$(TAG_VER).$(GOARCH).tgz

