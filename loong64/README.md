## 关于

此目录存放一些龙芯的编译，主要是二进制，基本都是 x86_64 上交叉编译的，推荐高内核的机器上编译，qemu 激活

```
docker run --rm --privileged registry.aliyuncs.com/zhangguanzhang/qemu-user-static --reset -p yes
```

## 关于 ABI 1.0 2.0

官方原装 golang 1.24+ 编译 GOARCH=loong64 的二进制是能在 5.19 内核以上的 ABI2.0 龙芯才能运行，在老的内核是 4.19龙芯给的 ABI1.0 系统上运行会报段错误，一些老的文件里 golang 都在 old-lib里，暂时不使用了。

默认 `make build` 是 ABI=2.0，部分目录内支持 `make build ABI=1.0`，不支持 1.0 的会在 README 里说明，临近版本里优先使用新版本。
