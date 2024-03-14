## 关于

此目录存放一些龙芯的编译，主要是二进制，基本都是 x86_64 上交叉编译的，推荐高内核的机器上编译，qemu 激活

```
docker run --rm --privileged registry.aliyuncs.com/zhangguanzhang/qemu-user-static --reset -p yes
```

官方原装 golang 1.19+ 编译 GOARCH=loong64 的二进制是能在 5.19 内核以上的龙芯才能运行，在目前内核是 4.19龙芯给的系统上运行会报段错误。

`lib.Makefile` 里的镜像都是 amd64 基础镜像 + 能编译出 abi1.0 的 loong64 的 amd64 龙芯 golang，相关 [Dockerfile 地址在这里](https://github.com/zhangguanzhang/Dockerfile/tree/master/loong64/golang)
