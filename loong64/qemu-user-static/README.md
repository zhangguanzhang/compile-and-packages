# abi1.0

使用 [Loongson-Cloud-Community/qemu-user-static](https://github.com/Loongson-Cloud-Community/qemu-user-static/releases) abi1.0 的 qemu-loongarch64-static 会无法运行 `loongnix-server:8.4` 的 `dnf`

```shell
$ docker run --rm -ti  cr.loongnix.cn/loongson/loongnix-server:8.4 dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False tzdata findutils
WARNING: The requested image's platform (linux/loong64) does not match the detected host platform (linux/amd64/v3) and no specific platform was requested
Failed to set locale, defaulting to C.UTF-8
Segmentation fault (core dumped)
```

使用编译后的测试没问题

```shell
$ docker run --rm --privileged zhangguanzhang/qemu-user-static:9.2-loong64 --reset -p yes
$ docker run --rm -ti cr.loongnix.cn/loongson/loongnix-server:8.4 dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False tzdata findutils
WARNING: The requested image's platform (linux/loong64) does not match the detected host platform (linux/amd64/v3) and no specific platform was requested
Loongnix server 8.4 - BaseOS                                                                                                                                                                                1.0 MB/s |  19 MB     00:19    
Loongnix server 8.4 - AppStream                                                                                                                                                                             2.2 MB/s |  14 MB     00:06    
Loongnix server 8.4 - Extras                                                                                                                                                                                 42 kB/s | 7.4 kB     00:00    
Loongnix server 8.4 - infra-buildtools-common                                                                                                                                                               1.0 MB/s | 626 kB     00:00    
Loongnix server 8.4 - infra-gitforge-pagure                                                                                                                                                                 209 kB/s |  55 kB     00:00    
Loongnix server 8.4 - infra-common                                                                                                                                                                          455 kB/s | 195 kB     00:00    
Package tzdata-2021e-1.lns8.noarch is already installed.
Package findutils-1:4.6.0-20.lns8.loongarch64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!

$ docker run --rm -ti cr.loongnix.cn/library/alpine:3.11.11 uname -m
WARNING: The requested image's platform (linux/loong64) does not match the detected host platform (linux/amd64/v3) and no specific platform was requested
loongarch64
```
