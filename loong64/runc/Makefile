include ../../lib.Makefile
include ../lib.Makefile

SOURCE_URL=https://github.com/opencontainers/runc
SOURCE=$(shell echo $(SOURCE_URL) | awk -F '/' '{print $$NF}' | awk -F '.' '{print $$1}')

TAG ?= v1.1.12

default: build

build_src/$(SOURCE):
	git clone -b $(TAG) --depth=1 $(SOURCE_URL) $@
	if [ -d $(TAG) ]; then cd $@ && \
		git apply ../../$(TAG)/*.patch; fi

build: build_src/$(SOURCE)
	# cd build_src/$(SOURCE) && make CONTAINER_ENGINE_BUILD_FLAGS="--build-arg GO_IMG=$(CC_GO_IMG)" RELEASE_ARGS="-a $(GOARCH)" release
	cd build_src/$(SOURCE) && \
		docker run --rm -e GOARCH=$(GOARCH) \
		-v `pwd`/build_src/$(SOURCE):/v -w /v $(GO_IMG) make static
