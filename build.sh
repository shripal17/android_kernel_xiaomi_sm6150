export ARCH=arm64
export KBUILD_BUILD_USER=ventur
export PATH="$(pwd)/toolchain"/bin/:$PATH

make O=out ARCH=arm64 phoenix_defconfig
make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    LLVM_IAS=1 \
    CC="ccache clang" \
    LD=ld.lld \
 CROSS_COMPILE=aarch64-linux-gnu- \
 CROSS_COMPILE_ARM32=arm-linux-gnueabi-
