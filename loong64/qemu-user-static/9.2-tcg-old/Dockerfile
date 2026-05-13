FROM busybox
ENV QEMU_BIN_DIR=/usr/bin
ADD https://raw.githubusercontent.com/zhangguanzhang/qemu-user-static/refs/heads/master/containers/latest/register.sh /register
ADD https://raw.githubusercontent.com/qemu/qemu/1887cf2368189087fdf977fb8d09b5ad47cc7aea/scripts/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh
RUN chmod +x /qemu-binfmt-conf.sh /register
COPY qemu-*-static /usr/bin/
ENTRYPOINT ["/register"]
