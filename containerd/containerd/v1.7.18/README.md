## about

- https://github.com/containerd/containerd/security/advisories/GHSA-265r-hfxg-fhmg

## 复现

奇怪的是复现不了

```shell
$ docker verison
Client:
 Version:           26.1.4
 API version:       1.45
 Go version:        go1.21.11
 Git commit:        5650f9b
 Built:             Wed Jun  5 11:27:57 2024
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          26.1.4
  API version:      1.45 (minimum version 1.24)
  Go version:       go1.21.11
  Git commit:       de5c9cf
  Built:            Wed Jun  5 11:29:25 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.7.18
  GitCommit:        ae71819c4f5e67bb4d5ae76a6b735f29cc25774e
 runc:
  Version:          1.1.12
  GitCommit:        v1.1.12-0-g51d5e94
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

一堆 CVE 文章，就是没有人说怎么复现，github 搜到 https://github.com/yen5004/CVE-2024-40635_POC 看了下脚本就是创建容器指定 user，尝试无法复现：

```shell
$ docker pull m.daocloud.io/docker.io/library/alpine
$ curl --unix /var/run/docker.sock http:/containers/create?name=t1 \
    -H 'Content-Type: application/json' \
  -d '
{
   "Image": "m.daocloud.io/docker.io/library/alpine",
   "User": "2147483648:2147483648",
   "Tty": true,
   "Entrypoint": ["/bin/sh"]
}
'
$ docker start t1
Error response from daemon: uids and gids must be in range 0-2147483647
```

想着直接通过 containerd 试试，发现也不行：

```shell
$ ctr --address /run/docker/containerd/containerd.sock images pull docker.io/library/alpine:latest
docker.io/library/alpine:latest:                                                  resolved       |++++++++++++++++++++++++++++++++++++++| 
index-sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c:    done           |++++++++++++++++++++++++++++++++++++++| 
manifest-sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474: done           |++++++++++++++++++++++++++++++++++++++| 
layer-sha256:f18232174bc91741fdf3da96d85011092101a032a93a388b79e99e69c2d5c870:    done           |++++++++++++++++++++++++++++++++++++++| 
config-sha256:aded1e1a5b3705116fa0a92ba074a5e0b0031647d9c315983ccba2ee5428ec8b:   done           |++++++++++++++++++++++++++++++++++++++| 
elapsed: 8.0 s                                                                    total:  10.6 K (1.3 KiB/s)                                       
unpacking linux/amd64 sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c...
done: 228.99917ms	
$ ctr --address /run/docker/containerd/containerd.sock  run --user 2147483648:2147483648 --rm docker.io/library/alpine:latest id
ctr: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: unable to setup user: uids and gids must be in range 0-2147483647: unknown
```

编译替换后走到用户名逻辑：

```shell
root/ctr --address /run/docker/containerd/containerd.sock  run --user 2147483648:2147483648 --rm docker.io/library/alpine:latest id
ctr: mount callback failed on /run/user/0/containerd-mount415484785: no users found
```

由于 docker 是通过 socket 向 containerd 调用的，所以理论只更新 containerd 二进制即可。

## 参考

- https://github.com/containerd/containerd/blob/main/BUILDING.md
- https://docs.docker.com/reference/api/engine/version/v1.45/#tag/Container/operation/ContainerCreate
