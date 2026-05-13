include ../../../lib.Makefile
include ../../lib.Makefile

SOURCE_URL=https://github.com/opencontainers/runc
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.3.5

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	cd $@ && \
		git apply ../../0001-support-loong64-ABI$(ABI).patch

build-ABI2.0:
	make -C build_src/$(SOURCE) releaseall \
		CONTAINER_ENGINE_BUILD_FLAGS='--build-arg GO_IMG=m.daocloud.io/docker.io/library/golang:1.25-trixie' CONTAINER_ENGINE_RUN_FLAGS='-e GOARCH=loong64'
build-ABI1.0:
	make -C build_src/$(SOURCE) releaseall \
		CONTAINER_ENGINE_BUILD_FLAGS='--build-arg GO_IMG=$(GO_IMG)' CONTAINER_ENGINE_RUN_FLAGS='-e GOARCH=loong64'

build: build_src/$(SOURCE) build-ABI$(ABI)
	cp build_src/$(SOURCE)/release/$(patsubst v%,%,$(TAG))/runc.loong64 runc
