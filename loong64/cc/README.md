## about

debian 新版本适配了龙芯的 abi2.0 ，而且它 apt 里带了交叉编译工具链，打包下 apt 里的交叉编译工具链和 abi1.0 的交叉编译工具链，使用

```shell
# abi2.0
export CC=loongarch64-linux-gnu-gcc
make ...

# abi1.0
export PATH=/loongson-gnu-toolchain/bin:$PATH
export CC=loongarch64-linux-gnu-gcc
make ...
```
