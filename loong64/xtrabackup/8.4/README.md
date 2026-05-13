
## about

https://github.com/percona/percona-xtrabackup/tree/trunk/storage/innobase/xtrabackup/doc/docs/installation
https://github.com/percona/percona-docker/tree/main/percona-xtrabackup-8.x

## 一些信息

```shell
$ docker run --rm -ti -u 0 --entrypoint bash m.daocloud.io/docker.io/percona/percona-xtrabackup:8.4
[root@8c6b8c8c2ced /]# rpm -qa | grep percona
percona-release-1.0-32.noarch
percona-server-shared-8.4.7-7.1.el9.x86_64
percona-xtradb-cluster-garbd-8.4.7-7.1.el9.x86_64
percona-xtrabackup-84-8.4.0-5.1.el9.x86_64
percona-server-client-8.4.7-7.1.el9.x86_64
[root@8c6b8c8c2ced /]# rpm -qa | grep xtra
percona-xtradb-cluster-garbd-8.4.7-7.1.el9.x86_64
percona-xtrabackup-84-8.4.0-5.1.el9.x86_64
```

## 龙芯

编译参考：
- [docker-image-that-builds-percona-from-source](https://forums.percona.com/t/docker-image-that-builds-percona-from-source/13908/6)
- [how-to-build-percona-server-for-mysql-from-sources](https://www.percona.com/blog/how-to-build-percona-server-for-mysql-from-sources/)

### percona-xtrabackup

根据官方文档 [apt-repo](https://docs.percona.com/percona-xtrabackup/8.4/apt-repo.html) 尝试发现不行：

```shell
$ docker run --rm -ti --entrypoint bash lcr.loongnix.cn/library/debian:14-slim
$ sed -ri '\@deb.debian.org/debian@s/[a-zA-Z0-9.]+(debian.org|ubuntu.com)/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources
$ apt update
$ apt install -y --no-install-recommends \
    curl
$ curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
$ apt install -y gnupg2 lsb-release ./percona-release_latest.generic_all.deb
$ apt update
$ percona-release enable pxb-84-lts
Specified repository is not supported for current operating system!
```

abi1.0 上，发现 python 下面会报错 `[Xtrabackup] rsync failed with error code 1`:

```python
signal.signal(signal.SIGCHLD,signal.SIG_IGN)
subprocess.Popen("xtrabackup")
```

改为：

```python
if platform.machine() == 'loongarch64':
    signal.signal(signal.SIGCHLD,signal.SIG_DFL)
else:
    signal.signal(signal.SIGCHLD,signal.SIG_IGN)
```


### percona-server-client

deb 包的话 mysqlbinlog 实际在 percona-server-server 里，并且 js 相关会编译失败，只有 mysqlx 使用 js，所以我是去掉的

```shell
$ find . -type f -exec grep -l WITH_JS_LANG {} \;
./percona-server-8.4.7-7/build-ps/percona-server.spec
./percona-server-8.4.7-7/build-ps/build-binary.sh
./percona-server-8.4.7-7/build-ps/debian/rules
./percona-server-8.4.7-7/components/js_lang/CMakeLists.txt
./percona-server-8.4.7-7/components/js_lang/README.md
./percona-server-8.4.7-7/debian/rules
./percona-server-8.4.7-7/debug/CMakeCache.txt
```
