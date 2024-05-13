export CLANG_PATH=/home/sajad/toolchains/clang-r510928
export PATH=${CLANG_PATH}/bin:${PATH}

export ARCH=arm64
export KBUILD_BUILD_USER=ventur
export KBUILD_BUILD_HOST=Sajad-PC

# Clean the build directory
make clean O=out ARCH=arm64

# Remove any configuration or generated files 
make mrproper O=out ARCH=arm64

# Load the configuration file
make phoenix_defconfig O=out ARCH=arm64

# Build the kernel
make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    LLVM_IAS=1 \
    CC="ccache clang" \
    LD=ld.lld \
    CROSS_COMPILE="/home/sajad/toolchains/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-" \
    CROSS_COMPILE_ARM32="/home/sajad/toolchains/arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-"

