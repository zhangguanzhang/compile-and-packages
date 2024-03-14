## 关于

交叉编译，按照 release 带 libseccomp 在打 patch 后 script/seccomp.sh 的 make install 的时候报错

```
make CONTAINER_ENGINE_BUILD_FLAGS="--build-arg GO_IMG=registry.aliyuncs.com/zhangguanzhang/loong64:go1.21-cc" RELEASE_ARGS="-a loong64" release
```

错误日志：
```
arch-loongarch64.c:40:3: error: 'const struct arch_def' has no member named 'syscall_name_kver'
   40 |  .syscall_name_kver = loongarch64_syscall_name_kver,
      |   ^~~~~~~~~~~~~~~~~
arch-loongarch64.c:40:23: error: 'loongarch64_syscall_name_kver' undeclared here (not in a function); did you mean 'loongarch64_syscall_iterate'?
   40 |  .syscall_name_kver = loongarch64_syscall_name_kver,
      |                       ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      |                       loongarch64_syscall_iterate
arch-loongarch64.c:40:23: warning: excess elements in struct initializer
arch-loongarch64.c:40:23: note: (near initialization for 'arch_def_loongarch64')
arch-loongarch64.c:41:3: error: 'const struct arch_def' has no member named 'syscall_num_kver'
   41 |  .syscall_num_kver = loongarch64_syscall_num_kver,
      |   ^~~~~~~~~~~~~~~~
arch-loongarch64.c:41:22: error: 'loongarch64_syscall_num_kver' undeclared here (not in a function); did you mean 'loongarch64_syscall_iterate'?
   41 |  .syscall_num_kver = loongarch64_syscall_num_kver,
      |                      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
      |                      loongarch64_syscall_iterate
arch-loongarch64.c:41:22: warning: excess elements in struct initializer
arch-loongarch64.c:41:22: note: (near initialization for 'arch_def_loongarch64')
make[2]: *** [Makefile:807: libseccomp_la-arch-loongarch64.lo] Error 1
make[1]: *** [Makefile:910: install-recursive] Error 1
make: *** [Makefile:525: install-recursive] Error 1
```

最好还是龙芯机器上去编译，不要 docker 交叉编译

## 相关 pr 链路
- https://github.com/opencontainers/runc/pull/3765
