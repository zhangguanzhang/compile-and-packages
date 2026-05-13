include ../../../lib.Makefile
include ../../lib.Makefile

SOURCE_URL=https://github.com/etcd-io/etcd
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v3.5.29
TG_FILE ?= etcd-$(TAG)-linux-loong64

default: build

build_src/$(SOURCE):
	git clone -c core.symlinks=true -b $(TAG) --depth=1 --recursive $(SOURCE_URL) $@
# 	if [ -d $(TAG) ]; then cd $@ && \
# 		git apply ../../$(TAG)/*.patch; fi
build: build_src/$(SOURCE)
	cd build_src/$(SOURCE) && \
		sed -ri 's#ppc64le#loong64#' server/etcdmain/etcd.go && \
		sed -ri '\%^\s+./bin/etcd.+version\s*$$%s#version#version || :#' Makefile && \
		docker run --rm -e GOARCH=$(GOARCH) \
			-v `pwd`:/v -w /v $(GO_IMG) make build && \
		mkdir -p $(CURDIR)/$(TG_FILE) && \
		cp bin/etcd* $(CURDIR)/$(TG_FILE) && \
		cd $(CURDIR)/ && \
		tar zcf $(CURDIR)/$(TG_FILE).tar.gz $(TG_FILE) && \
		rm -rf $(TG_FILE)
