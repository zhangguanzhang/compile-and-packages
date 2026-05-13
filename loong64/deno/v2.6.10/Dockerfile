FROM m.daocloud.io/docker.io/openeuler/openeuler:24.03-lts-sp3

WORKDIR /mnt

RUN set -eux; \
    sed -ri 's|://repo.openeuler.org/|://repo.huaweicloud.com/openeuler/|g' /etc/yum.repos.d/openEuler.repo; \
    sed -ri 's|https://mirrors.openeuler.org|https://repo.huaweicloud.com/openeuler/|g' /etc/yum.repos.d/openEuler.repo; \  
    dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
        wget git xz diffutils findutils \
        automake autoconf gcc gcc-c++ make cmake zlib-devel openssl-devel expat-devel \
    ; \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
    . "$HOME/.cargo/env"; \
    rustup target add loongarch64-unknown-linux-gnu; \
    rustc --version --verbose; \
    # Install cago-binstall
    cargo install cargo-binstall; \
    # Install nextest
    cargo binstall cargo-nextest --secure --locked --no-confirm; \
    # Install Clang and libs  # clang llvm llvm-devel clang-tools-extra \
    dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
        ccache ninja-build libstdc++-static \
        glib2-devel compiler-rt glibc-devel libgcc libstdc++-devel \
        llvm-toolset-20-clang \
        llvm-toolset-20-compiler-rt \
        llvm-toolset-20-llvm \
        llvm-toolset-20-libcxx \
        llvm-toolset-20-libcxx-devel \
        lld \
    ; \
    for file in clang clang++ clang-cl clang-cpp;do \
        ln -sf /usr/bin/${file}-20 /usr/bin/${file}; \
    done; \
    clang --version; \
    ninja --version; \
    git clone https://github.com/denoland/rusty_v8.git; \
    cd rusty_v8; \
    git submodule update --init --recursive; \
    if [ `uname -m` = loongarch64 ];then \
        gn_version=$(awk -F"[': ]+" '$0~"gn_version"{print $4;exit}' v8/DEPS); \
        git clone https://gn.googlesource.com/gn /mnt/gn; \
        cd /mnt/gn; \
        git checkout ${gn_version}; \
        CFLAGS="-Wno-error=deprecated-declarations" CXXFLAGS="-Wno-error=deprecated-declarations"  python3 build/gen.py; \
        CFLAGS="-Wno-error=deprecated-declarations" CXXFLAGS="-Wno-error=deprecated-declarations" ninja -C out; \
        cp out/gn /usr/local/bin/gn; \
        gn --version; \
        cd -; \
        git clone https://github.com/google/crubit.git; \
        cd crubit; \
        cargo build --bin cc_bindings_from_rs; \
        cc_rs=$(readlink -f ./target/debug/cc_bindings_from_rs); \
        cd -; \
            echo '#!/bin/bash' > third_party/rust-toolchain/bin/cc_bindings_from_rs; \
            echo "LD_LIBRARY_PATH=$(rustc --print sysroot)/lib:$LD_LIBRARY_PATH ${cc_rs}" >> third_party/rust-toolchain/bin/cc_bindings_from_rs; \
            chmod a+x third_party/rust-toolchain/bin/cc_bindings_from_rs; \
    fi ; \

    rustup component add rust-src; \
    cargo install bindgen-cli --version 0.72.0; \
    cp `which bindgen` third_party/rust-toolchain/bin/; \

    for file in bindgen cargo cargo-clippy cargo-fmt rust-analyzer clippy-driver rustc rustfmt; do
        \cp $(rustc --print sysroot)/bin/${file} third_party/rust-toolchain/bin/; \
    done

    CLANG_MAJOR_VER=$(clang --version | awk -F '[ .]+' '$2=="version"{print $3;exit}'); \
    if [ -d "/usr/lib/clang/${CLANG_MAJOR_VER}/lib/loongarch64-openEuler-linux-gnu" ];then \
        ln -sf "/usr/lib/clang/${CLANG_MAJOR_VER}/lib/loongarch64-openEuler-linux-gnu" "/usr/lib/clang/${CLANG_MAJOR_VER}/lib/loongarch64-unknown-linux-gnu"; \
    fi; \
    if [ -d "/usr/lib/clang/${CLANG_MAJOR_VER}/lib/x86_64-openEuler-linux-gnu" ];then \
        ln -sf "/usr/lib/clang/${CLANG_MAJOR_VER}/lib/x86_64-openEuler-linux-gnu" "/usr/lib/clang/${CLANG_MAJOR_VER}/lib/x86_64-unknown-linux-gnu"; \
    fi; \

    cd /opt/openEuler/llvm-toolset-20/root/usr/lib64/clang/20/lib/
    ln -sf loongarch64-openEuler-linux-gnu loongarch64-unknown-linux-gnu

    /usr/lib/clang/23/lib/loongarch64-unknown-linux-gnu/

    CLANG_BASE_PATH=/usr V8_FROM_SOURCE=1  LIB_NAME=librusty_v8 cargo build -vv --target loongarch64-unknown-linux-gnu

    ./target/debug/deno run cli/tests/testdata/002_hello.ts

docker run --privileged --rm  lcr.loongnix.cn/tonistiigi/binfmt:latest --install amd64

tar -hzcf /root/x86_64_rootfs libz.so.1 libdl.so.2 libc.so.6 libgcc_s.so.1 libm.so.6 libpthread.so.0 ld-linux-x86-64.so.2
# ./tools/rust_toolchain.py 下载的 x86_64 rust 会 bash: third_party/rust-toolchain/bin/rustc: cannot execute binary file: Exec format error

#!/bin/bash
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
c=$(basename $0)
LD_LIBRARY_PATH=/x86_64-lib64/ ${CUR_DIR}/${c}_raw $@

CLANG_BASE_PATH=/opt/openEuler/llvm-toolset-20/root/usr CXX=/opt/openEuler/llvm-toolset-20/root/usr/bin/clang++ AR=/opt/openEuler/llvm-toolset-20/root/usr/bin/llvm-ar NM=/opt/openEuler/llvm-toolset-20/root/usr/bin/llvm-nm CC=/opt/openEuler/llvm-toolset-20/root/usr/bin/clang CXX=/opt/openEuler/llvm-toolset-20/root/usr/bin/clang++ V8_FROM_SOURCE=1  LIB_NAME=librusty_v8 cargo build -vv --target loongarch64-unknown-linux-gnu
