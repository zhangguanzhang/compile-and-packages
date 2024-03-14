include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/helm/helm
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

# v3.14.2
TAG ?= v3.14.3

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build: build_src/$(SOURCE)
	docker run --rm -e GOARCH=$(GOARCH) \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(GO_IMG) make build
	mkdir -p linux-$(GOARCH)
	mv build_src/$(SOURCE)/bin/helm linux-$(GOARCH)/
	tar zcf helm-$(TAG)-linux-$(GOARCH).tar.gz linux-$(GOARCH)/
	rm -rf linux-$(GOARCH)/
