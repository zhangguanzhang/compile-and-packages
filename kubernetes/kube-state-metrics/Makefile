include ../../lib.Makefile

SOURCE_URL=https://github.com/kubernetes/kube-state-metrics.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v2.13.0
IMAGE_ARCH ?= amd64 arm64
GOLANG_VERSION ?= $(shell go version | awk '{gsub("go", "",$$3);print $$3}')

default: image

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	sed -ri '/^GO_VERSION/s#\s=# ?=#' build_src/$(SOURCE)/Makefile
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

image: source
	for arch in $(IMAGE_ARCH); do \
		make -C build_src/$(SOURCE) container ARCH=$${arch} TAG=$(TAG) GO_VERSION=1.23; \
	done

clean:
	rm -rf build_src
