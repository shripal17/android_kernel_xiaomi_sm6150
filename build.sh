#!/bin/bash

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'
ZIMG=./out/arch/arm64/boot/Image.gz-dtb
OUTPUT_DIR=./../Paradox_release

export LOCALVERSION=-v3.9

rm -f $ZIMG

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export CLANG_PATH=/home/pzqqt/build_toolchain/clang-r445002-14.0.2

export KBUILD_BUILD_HOST="wsl2"
export KBUILD_BUILD_USER="pzqqt"

export PATH=${CLANG_PATH}/bin:${PATH}

ccache_=`which ccache` || {
	ccache_=
	echo -e "${yellow}Warning: ccache is not used! $white"
}

make mrproper O=out || exit 1
make phoenix_defconfig O=out || exit 1

Start=$(date +"%s")

make -j$(nproc --all) \
	O=out \
	CC="${ccache_} clang" \
	AS=llvm-as \
	LD=ld.lld \
	AR=llvm-ar \
	NM=llvm-nm \
	STRIP=llvm-strip \
	OBJCOPY=llvm-objcopy \
	OBJDUMP=llvm-objdump \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE="/home/pzqqt/build_toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-" \
	CROSS_COMPILE_ARM32="/home/pzqqt/build_toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-"

exit_code=$?
End=$(date +"%s")
Diff=$(($End - $Start))

if [ -f $ZIMG ]; then
	mkdir -p $OUTPUT_DIR
	cp -f ./out/arch/arm64/boot/Image.gz $OUTPUT_DIR/Image.gz
	cp -f ./out/arch/arm64/boot/dts/qcom/sdmmagpie.dtb $OUTPUT_DIR/dtb
	cp -f ./out/arch/arm64/boot/dtbo.img $OUTPUT_DIR/dtbo.img
	which avbtool &>/dev/null && {
		python2 `which avbtool` add_hash_footer \
			--partition_name dtbo \
			--partition_size $((32 * 1024 * 1024)) \
			--image $OUTPUT_DIR/dtbo.img
	} || {
		echo -e "${yellow}Warning: Skip adding hashes and footer to dtbo image! $white"
	}
	cat ./out/modules.order | while read line; do
		module_file=./out/${line#*/}
		[ -f $module_file ] && cp -f $module_file $OUTPUT_DIR
	done
	for f in `ls -1 $OUTPUT_DIR | grep '.ko$'`; do
		llvm-strip -S ${OUTPUT_DIR}/$f &
	done
	wait
	echo -e "$gre << Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >> \n $white"
else
	echo -e "$red << Failed to compile Image.gz-dtb, fix the errors first >>$white"
	exit $exit_code
fi
