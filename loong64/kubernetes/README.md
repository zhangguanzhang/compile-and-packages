## 参考

https://github.com/Loongson-Cloud-Community/kubernetes/blob/1.18.6-loong64/build.sh

```
# KUBE_BASE_IMAGE_REGISTRY=cr.loongnix.cn/k8s-build-image KUBE_CROSS_VERSION=latest #KUBE_BUILD_PULL_LATEST_IMAGES=no make release-images 
KUBE_BUILD_PLATFORMS=linux/loong64  KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_HYPERKUBE=n make quick-release # GOFLAGS=-v
```

然后在目录 `_output/release-tars/`

## 一些说明

似乎暂时无法使用 qemu + 龙芯镜像编译，只能 hack kube-cross 里的 golang 为 abi 1.0 的 amd64 golang 编译

龙芯提供的 patch 文件里一些镜像相关的 diff，可以拿去参考下

```diff
diff --git a/build/common.sh b/build/common.sh
index df0a9d60..268db9be 100755
--- a/build/common.sh
+++ b/build/common.sh
@@ -41,8 +41,10 @@ readonly KUBE_BUILD_IMAGE_REPO=kube-build
 KUBE_BUILD_IMAGE_CROSS_TAG="$(cat "${KUBE_ROOT}/build/build-image/cross/VERSION")"
 readonly KUBE_BUILD_IMAGE_CROSS_TAG
 
-readonly KUBE_DOCKER_REGISTRY="${KUBE_DOCKER_REGISTRY:-registry.k8s.io}"
-KUBE_BASE_IMAGE_REGISTRY="${KUBE_BASE_IMAGE_REGISTRY:-registry.k8s.io/build-image}"
+#readonly KUBE_DOCKER_REGISTRY="${KUBE_DOCKER_REGISTRY:-registry.k8s.io}"
+#KUBE_BASE_IMAGE_REGISTRY="${KUBE_BASE_IMAGE_REGISTRY:-registry.k8s.io/build-image}"
+readonly KUBE_DOCKER_REGISTRY="${KUBE_DOCKER_REGISTRY:-cr.loongnix.cn/kubernetes}"
+readonly KUBE_BASE_IMAGE_REGISTRY="${KUBE_BASE_IMAGE_REGISTRY:-cr.loongnix.cn/k8s-build-image}"
 readonly KUBE_BASE_IMAGE_REGISTRY
 
 # This version number is used to cause everyone to rebuild their data containers
@@ -95,9 +97,12 @@ readonly KUBE_RSYNC_PORT="${KUBE_RSYNC_PORT:-}"
 readonly KUBE_CONTAINER_RSYNC_PORT=8730
 
 # These are the default versions (image tags) for their respective base images.
-readonly __default_distroless_iptables_version=v0.4.5
-readonly __default_go_runner_version=v2.3.1-go1.21.7-bullseye.0
-readonly __default_setcap_version=bullseye-v1.4.2
+readonly __default_distroless_iptables_version=latest
+#readonly __default_distroless_iptables_version=v0.4.5
+#readonly __default_go_runner_version=v2.3.1-go1.21.7-bullseye.0
+#readonly __default_setcap_version=bullseye-v1.4.2
+readonly __default_go_runner_version=latest
+readonly __default_setcap_version=latest
 
 # These are the base images for the Docker-wrapped binaries.
 readonly KUBE_GORUNNER_IMAGE="${KUBE_GORUNNER_IMAGE:-$KUBE_BASE_IMAGE_REGISTRY/go-runner:$__default_go_runner_version}"
@@ -119,6 +124,8 @@ readonly KUBE_BUILD_SETCAP_IMAGE="${KUBE_BUILD_SETCAP_IMAGE:-$KUBE_BASE_IMAGE_RE
 kube::build::get_docker_wrapped_binaries() {
   ### If you change any of these lists, please also update DOCKERIZED_BINARIES
   ### in build/BUILD. And kube::golang::server_image_targets
+    local debian_iptables_version=latest
+    local go_runner_version=latest
   local targets=(
     "kube-apiserver,${KUBE_APISERVER_BASE_IMAGE}"
     "kube-controller-manager,${KUBE_CONTROLLER_MANAGER_BASE_IMAGE}"
```