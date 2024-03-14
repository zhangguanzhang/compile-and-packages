include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/cloudflare/cfssl
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.6.5

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build: build_src/$(SOURCE)
	docker run --rm -e GOARCH=$(GOARCH) \
		-e CGO_ENABLED=0 \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(GO_IMG) \
		sh -c 'TARGETOS=linux TARGETARCH=loong64 make bin/cfssl bin/cfssl-certinfo bin/cfssljson'

