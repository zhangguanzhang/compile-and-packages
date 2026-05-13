include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/kubernetes/kubernetes
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')
# v1.27.11
TAG ?= v1.27.16

default: build

build_src/$(SOURCE):
	git clone -c core.symlinks=true -b $(TAG) --depth=1 --recursive $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi
# KUBE_CROSS_IMAGE=m.daocloud.io/registry.k8s.io/build-image/kube-cross KUBE_CROSS_VERSION=v1.34.0-go1.24.11-bullseye.0
build: build_src/$(SOURCE)
	cd build_src/$(SOURCE) && \
		KUBE_BUILD_PLATFORMS=linux/loong64  \
		KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_HYPERKUBE=n make quick-release
