include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/containernetworking/plugins
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.9.0

default: build

build_src/$(SOURCE):
	git clone -c core.symlinks=true -b $(TAG) --depth=1 --recursive $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi
build: build_src/$(SOURCE)
	rm -rf build_src/$(SOURCE)/bin/*
	cd build_src/$(SOURCE) && \
		CGO_ENABLED=0 GOARCH=loong64 ./build_linux.sh -ldflags '-extldflags -static -X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=$(TAG)' && \
		cd bin && \
		tar cfzpv $(CURDIR)/cni-plugins-linux-loong64-$(TAG).tgz .
