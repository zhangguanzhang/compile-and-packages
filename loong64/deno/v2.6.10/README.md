# Cross Build Deno

docker:debian:unstable


https://github.com/denoland/rusty_v8/blob/main/.github/workflows/ci.yml


> official for aarch64
        sudo apt install -yq --no-install-suggests --no-install-recommends \
            binfmt-support g++-10-aarch64-linux-gnu g++-10-multilib \
            gcc-10-aarch64-linux-gnu libc6-arm64-cross qemu qemu-user \
            qemu-user-binfmt
ln -s /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 \
                     /lib/ld-linux-aarch64.so.1

          echo "CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=/usr/bin/aarch64-linux-gnu-gcc-10" >> ${GITHUB_ENV}
          echo "QEMU_LD_PREFIX=/usr/aarch64-linux-gnu" >> ${GITHUB_ENV}
rustup target add aarch64-unknown-linux-gnu

echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-19 main" | sudo dd of=/etc/apt/sources.list.d/llvm-toolchain-jammy-19.list
apt-get install lld-19 clang-19 clang-tools-19 clang-tidy-19 clang-format-19 libclang-19-dev -y
 echo "LIBCLANG_PATH=/usr/lib/llvm-19/lib" >> $GITHUB_ENV

> for loong64

apt install gcc-15-loongarch64-linux-gnu g++-15-multilib gcc-15-aarch64-linux-gnu libc6-loong64-cross
ln -s /usr/loongarch64-linux-gnu/lib/ld-linux-loongarch-lp64d.so.1 /lib/ld-linux-loongarch-lp64d.so.1
echo CARGO_TARGET_LOONGARCH64_UNKNOWN_LINUX_GNU_LINKER=/usr/bin/loongarch64-linux-gnu-gcc-15  >> ~/.bashlocal
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

rustup target add loongarch64-unknown-linux-gnu

echo "deb [truser=true] http://apt.llvm.org/trixie/ llvm-toolchain-trixie-21 main" | sudo dd of=/etc/apt/sources.list.d/llvm-toolchain-trixie-21.list
apt-get install lld-21 clang-21 clang-tools-21 clang-tidy-21 clang-format-21 libclang-21-dev -y

echo "export LIBCLANG_PATH=/usr/lib/llvm-21/lib" >> ~/.bashlocal


> beging
V8_FROM_SOURCE=1 cargo build -vv --target loongarch64-unknown-linux-gnu

网络问题，下载 ninja 需要白名单
RESOLVE_URL = 'https://chrome-infra-packages.appspot.com/_ah/api/repo/v1/instance/resolve?package_name={}&version={}'
INSTANCE_URL = 'https://chrome-infra-packages.appspot.com/_ah/api/repo/v1/instance?package_name={}&instance_id={}'

diff --git a/tools/ninja_gn_binaries.py b/tools/ninja_gn_binaries.py
index de4a376..2c6733a 100755
--- a/tools/ninja_gn_binaries.py
+++ b/tools/ninja_gn_binaries.py
@@ -72,7 +72,15 @@ def DownloadAndUnpack(url, output_dir):
 def DownloadCIPD(package, tag, output_dir):
     def get(url):
         parsed = urlparse(url)
-        conn = http.client.HTTPSConnection(parsed.netloc)
+        # --- <E9><85><8D><E7><BD><AE><E4><BB><A3><E7><90><86>
+        proxy_host = "10.2.10.197"
+        proxy_port = 7890
+
+        conn = http.client.HTTPSConnection(proxy_host, proxy_port)
+        conn.set_tunnel(parsed.netloc)
+        # ---<E4><BB><A3><E7><90><86><E7><BB><93><E6><9D><9F>
+
+        #conn = http.client.HTTPSConnection(parsed.netloc)

apt install libglib2.0-dev

历尽千辛万苦也是把 sysroot 搞出来了

放在这个目录?
/wk/rusty_v8/build/linux/debian_sid_loong64-sysroot


  --- stderr
  ninja: error: '../../../../../../usr/lib/llvm-21/lib/clang/21/lib/loongarch64-unknown-linux-gnu/libclang_rt.builtins.a', needed by 'obj/build/rust/allocator/liballoc_error_handler_impl.a', missing and no known rule to make it

从 chrome 下载的 clang 不具有 la 支持，可以使用系统自带的 clang
1. 设置环境变量
LIBCLANG_PATH=/usr/lib/llvm-21/lib
CLANG_BASE_PATH=/usr/lib/llvm-21

2. 从 la 处拷贝完成以下目录
# ls /usr/lib/llvm-21/lib/clang/21/lib/
linux/  loongarch64-unknown-linux-gnu/  x86_64-unknown-linux-gnu/
3. 在目录下建立正确名称的软链接
or file in $(ls libclang*x86_64.a); do ln -s $file ${file/-x86_64/}; done

[v8 145.0.0] cargo:rustc-env=RUSTY_V8_SRC_BINDING_PATH=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/gn_out/src_binding.rs
warning: v8@145.0.0: Not using sccache or ccache
     Running `CARGO=/root/.rustup/toolchains/1.89.0-x86_64-unknown-linux-gnu/bin/cargo CARGO_CRATE_NAME=v8 CARGO_MANIFEST_DIR=/wk/rusty_v8 CARGO_MANIFEST_PATH=/wk/rusty_v8/Cargo.toml CARGO_PKG_AUTHORS='the Deno authors' CARGO_PKG_DESCRIPTION='Rust bindings to V8' CARGO_PKG_HOMEPAGE='' CARGO_PKG_LICENSE=MIT CARGO_PKG_LICENSE_FILE='' CARGO_PKG_NAME=v8 CARGO_PKG_README=README.md CARGO_PKG_REPOSITORY='https://github.com/denoland/rusty_v8' CARGO_PKG_RUST_VERSION='' CARGO_PKG_VERSION=145.0.0 CARGO_PKG_VERSION_MAJOR=145 CARGO_PKG_VERSION_MINOR=0 CARGO_PKG_VERSION_PATCH=0 CARGO_PKG_VERSION_PRE='' CARGO_PRIMARY_PACKAGE=1 CARGO_SBOM_PATH='' GN_OUT_DIR=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/gn_out LD_LIBRARY_PATH='/wk/rusty_v8/target/debug/deps:/root/.rustup/toolchains/1.89.0-x86_64-unknown-linux-gnu/lib' OUT_DIR=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/build/v8-80990ffd4c21515c/out RUSTY_V8_SRC_BINDING_PATH=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/gn_out/src_binding.rs /root/.rustup/toolchains/1.89.0-x86_64-unknown-linux-gnu/bin/rustc --crate-name v8 --edition=2024 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=190 --crate-type lib --emit=dep-info,metadata,link -C opt-level=1 -C embed-bitcode=no -C debuginfo=2 -C debug-assertions=on --cfg 'feature="default"' --cfg 'feature="use_custom_libcxx"' --check-cfg 'cfg(docsrs,test)' --check-cfg 'cfg(feature, values("default", "use_custom_libcxx", "v8_enable_pointer_compression", "v8_enable_sandbox", "v8_enable_v8_checks"))' -C metadata=53c4f83236431121 -C extra-filename=-82786d298c4f5cec --out-dir /wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/deps --target loongarch64-unknown-linux-gnu -C linker=/usr/bin/loongarch64-linux-gnu-gcc-15 -C incremental=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/incremental -L dependency=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/deps -L dependency=/wk/rusty_v8/target/debug/deps --extern bitflags=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/deps/libbitflags-6d29fec957185eb4.rmeta --extern paste=/wk/rusty_v8/target/debug/deps/libpaste-7feb7d9c05f97717.so --extern temporal_capi=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/deps/libtemporal_capi-8cfa473d4edb3f6d.rmeta -L native=/wk/rusty_v8/target/loongarch64-unknown-linux-gnu/debug/gn_out/obj/ -l static=rusty_v8`

交叉构建 rusty_v8 完成

交叉构建 deno
apt install cmake make
cargo install --force --locked bindgen-cli

root@14e9fffcd9d6 /usr/bin 
ln -s loongarch64-linux-gnu-gcc-15 loongarch64-linux-gnu-gcc

warning: aws-lc-sys@0.29.0: Compiler family detection failed due to error: ToolNotFound: failed to find tool "loongarch64-linux-gnu-g++": No such file or directory (os error 2)


打补丁，再把 sysroot 拷贝过去

root@14e9fffcd9d6 /wk/archives/rusty_v8/build/linux 
# cp -R debian_unstable_loong64-sysroot /wk/v8-145.0.0/build/linux/
root@14e9fffcd9d6 /wk/archives/rusty_v8/build/linux 
# cp -R debian_sid_loong64-sysroot /wk/v8-145.0.0/build/linux/
root@14e9fffcd9d6 /wk/archives/rusty_v8/build/linux 
# cp -R debian_bullseye_amd64-sysroot  /wk/v8-145.0.0/build/linux/

error[E0080]: evaluation panicked: unsupported platform
    --> tests/util/server/src/servers/mod.rs:1496:29
     |
1496 | const TSGO_PLATFORM: &str = tsgo_platform();
     |                             ^^^^^^^^^^^^^^^ evaluation of `servers::TSGO_PLATFORM` failed inside this call

gn_out/obj:/wk/deno/target/debug/build/zstd-sys-7ed432ffcb42f79c/out' NUM_JOBS=16 OPT_LEVEL=0 OUT_DIR=/wk/deno/target/loongarch64-unknown-linux-gnu/debug/build/deno-feae747c3502c13d/out PROFILE=debug RUSTC=/root/.rustup/toolchains/1.92.0-x86_64-unknown-linux-gnu/bin/rustc RUSTC_LINKER=/usr/bin/loongarch64-linux-gnu-gcc-15 RUSTDOC=/root/.rustup/toolchains/1.92.0-x86_64-unknown-linux-gnu/bin/rustdoc TARGET=loongarch64-unknown-linux-gnu /wk/deno/target/debug/build/deno-ee7d8d605132da9e/build-script-build` (exit status: 101)
  --- stdout
  cargo:rustc-link-arg-bin=deno=-Wl,--export-dynamic-symbol-list=/wk/deno/ext/napi/generated_symbol_exports_list_linux.def

  --- stderr

  thread 'main' (139562) panicked at cli/build.rs:259:5:
  Cross compiling with snapshot is not supported.

export RUSTFLAGS="-C code-model=medium"
export CFLAGS="-mcmodel=medium"
export CXXFLAGS="-mcmodel=medium"