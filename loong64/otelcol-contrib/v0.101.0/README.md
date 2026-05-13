## about

```shell
go install go.opentelemetry.io/collector/cmd/builder@v0.101.0
git clone https://github.com/open-telemetry/opentelemetry-collector-releases
cd opentelemetry-collector-releases
# 龙芯 golang 编译镜像里挂载，如果abi2.0 本机 golang 交叉编译即可
GOARCH=loong64 make build OTELCOL_BUILDER=/go/bin/builder DISTRIBUTIONS=otelcol-contrib GEN_CONFIG_DISTRIBUTIONS=otelcol-contrib
# /go/pkg/mod/github.com/opencontainers/runc@v1.1.12/libcontainer/init_linux.go:415:19: undefined: system.Setgid
cp /go/pkg/mod/github.com/opencontainers/runc\@v1.1.12/ /tmp/runc
sed -ri 's#riscv64#loong64#g' /tmp/runc/libcontainer/system/syscall_linux_64.go
cd distributions/otelcol-contrib/_build
go mod edit -replace='github.com/opencontainers/runc@v1.1.12=/tmp/runc'
CGO_ENABLED=0 GOARCH=loong64 go build  -trimpath -ldflags='-s -w'  -o ../otelcol-contrib .
cd ..

# build docker image
vi Dockerfile
DOCKER_BUILDKIT=1 docker build . --load -t otel/opentelemetry-collector-contrib:0.101.0
```
