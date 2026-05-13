include ../../lib.Makefile

SOURCE_URL=https://github.com/flannel-io/flannel.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v0.25.4
IMAGE_ARCH ?= amd64 arm64
GOLANG_VERSION ?= $(shell go version | awk '{gsub("go", "",$$3);print $$3}')

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

clean:
	rm -rf build_src/$(SOURCE)

image: source
	for arch in $(IMAGE_ARCH); do \
		 make -C build_src/$(SOURCE) image ARCH=$${arch}; \
	done
