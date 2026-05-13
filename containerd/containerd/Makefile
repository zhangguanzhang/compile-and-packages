include ../../lib.Makefile

SOURCE_URL=https://github.com/containerd/containerd.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')
TAG ?= v1.7.18

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

bin: source
	make -C build_src/$(SOURCE) binaries STATIC=1
