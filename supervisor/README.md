## supervisor

主要是利用 pyinstaller 打包，打包时候使用的基础镜像的 glibc 要小于等于运行机器的版本，可以通过 `ldd --version` 看第一行结尾

## 说明

Dockerfile 我为啥这样写，想象下层缓存，改动最多的是 rpmbuild

### 构建命令

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
    --build-arg BASE_IMG=centos:7 . \
    -f buildx.Dockerfile \
    --target bin --output .
# 如果没同样 os 的不同架构，可以自行编译
docker build --build-arg BASE_IMG=centos:7 . \
    -f buildx.Dockerfile 
# 或者实机上 rpmbuild 构建，确保 rpmbuild 目录在 /root/ 下
cd rpmbuild
rpmbuild -bb SPECS/supervisor.spec --define="GOARCH $GOARCH" --define="version ${version}" 
```

### 一些说明

- `BASE_IMG=centos:7` 也可以换国产的 kylin uos 啥的镜像
- `env_file_support` 为 0 则不 hack 添加 environment_file 支持，buildx 的那个构建支持，后俩构建方式要支持自行琢磨
