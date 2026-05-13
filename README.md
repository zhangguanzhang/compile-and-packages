## compile-and-packages

自己使用的一些场景：
- 静态编译
- rpm 包制作
- 重新使用新镜像或同版本内新版本 go 编译解决 CVE 问题

基本是使用 docker buildx build 构建出成品文件，仅供参考
生成 patch 使用 `git format-patch HEAD~1`
对于一些 `make build` 构建二进制的，如果一个目录下支持多版本，记得切换版本 `make build` 之前先 `make clean`

## 说明

- [使用 buildx 构建多平台 Docker 镜像](https://github.com/zhangguanzhang/docker-need-to-know/blob/master/2.docker-image/dockerfile/buildx.md)
- [buildx 直接构建成果到宿主机上](https://github.com/zhangguanzhang/docker-need-to-know/blob/master/2.docker-image/dockerfile/buildx.md)
