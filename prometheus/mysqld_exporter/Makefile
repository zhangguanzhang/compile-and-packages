include ../../lib.Makefile

SOURCE_URL=https://github.com/prometheus/mysqld_exporter.git
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v0.15.1
IMAGE_ARCH ?= amd64 arm64
GOLANG_VERSION ?= $(shell go version | awk '{gsub("go", "",$$3);print $$3}')

IMAGE_NAME ?= prom/mysqld-exporter

default: image

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) build_src/$(SOURCE)
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

source: build_src/$(SOURCE)

image: source
	for arch in $(IMAGE_ARCH); do \
		make -C build_src/$(SOURCE) build DOCKER_ARCHS=$${arch} GOARCH=$${arch}; \
		mkdir -p build_src/$(SOURCE)/.build/linux-$${arch}/; \
		cp build_src/$(SOURCE)/mysqld_exporter build_src/$(SOURCE)/.build/linux-$${arch}/; \
		docker build build_src/$(SOURCE)/  -t $(IMAGE_NAME):$(TAG)-$${arch} --build-arg ARCH=$${arch} --build-arg OS="linux"; \
	done

clean:
	rm -rf build_src
