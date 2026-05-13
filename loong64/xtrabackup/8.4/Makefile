include ../../../lib.Makefile
include ../../lib.Makefile

BUILD_IMG ?= lcr.loongnix.cn/library/debian:14-slim
# 42GB + 27GB
BUILD_CACHE_PATH ?= /data
IMAGE_NAME ?= xtrabackup:8.4-loong64
DIST_CTR ?= dist-xtrabackup
DIST_URL ?= $(DOCKER0_IP):50358


dist-web:
	docker run -d --name $(DIST_CTR) --platform=linux/$(HOST_ARCH) \
		-v $$PWD/deb:/dist/ -p $(DIST_URL):8080 $(WEB_IMG) -listdir

# percona-xtrabackup 1h  percona-server 6h
percona-%:
	docker run --security-opt seccomp=unconfined -tid --name build-$@ \
		-v $(BUILD_CACHE_PATH)/percona-$*:/data/ -v $$PWD:/v  -w /v $(BUILD_IMG) && \
	docker exec -ti build-$@ bash scripts/$@.sh

image: dist-web percona-xtrabackup percona-server
	$(CONTAINER_RUNTIME) build . --build-arg DIST_URL=$(DIST_URL) \
		--build-arg IMG=$(BUILD_IMG) -t $(IMAGE_NAME)

# 有问题，gcc10不行， c++: error: unrecognized command line option '-std=c++20'; did you mean '-std=c++2a'?
# 推荐使用 cr.loongnix.cn/library/percona-xtrabackup:8.4.0-5
image-ABI1.0:
	$(MAKE) image BUILD_IMG=cr.loongnix.cn/library/debian:buster-slim WEB_IMG=$(WEB_IMG):loong64-abi1.0

clean:
	rm -rf $(BUILD_CACHE_PATH)/percona-* source_*
