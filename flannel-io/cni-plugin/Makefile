include ../../lib.Makefile

SOURCE_URL=https://github.com/flannel-io/cni-plugin.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.4.1-flannel1
IMAGE_ARCH ?= amd64 arm64
GOLANG_VERSION ?= $(shell go version | awk '{gsub("go", "",$$3);print $$3}')
ALPINE_VER ?= latest

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

clean:
	rm -rf build_src/$(SOURCE)

image: source
	sed -ri '/FROM alpine:/s#:.+#:$(ALPINE_VER)#' build_src/$(SOURCE)/Dockerfile.image
	for arch in $(IMAGE_ARCH); do \
		DOCKER_BUILDKIT=1  docker build build_src/$(SOURCE)/ -f build_src/$(SOURCE)/Dockerfile.image \
		 --platform=linux/$${arch} --pull --load \
		 -t flannel/flannel-cni-plugin:$(TAG)-$${arch} ; \
	done
