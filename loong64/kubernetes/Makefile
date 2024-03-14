include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/kubernetes/kubernetes
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')
# v1.27.11
TAG ?= v1.27.12

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build: build_src/$(SOURCE)
	cd build_src/$(SOURCE) && \
		KUBE_BUILD_PLATFORMS=linux/loong64 KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_HYPERKUBE=n make quick-release
