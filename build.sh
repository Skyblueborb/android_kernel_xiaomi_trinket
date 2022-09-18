#!/bin/bash

export PATH=$HOME/Desktop/proton-clang/bin:$PATH
export ARCH=arm64
export MAKEFLAGS=-j$(nproc --all)

export USE_CCACHE=1
export CCACHE_EXEC=$(command -v ccache)
export CCACHE_DIR=/mnt/TheBig/lineage/ccache

echo "+ PATH=$PATH"
echo "+ ARCH=$ARCH"

compile() {
    set -x
    make vendor/laurel_sprout-perf_defconfig O=out
    make -k O=out CC="ccache clang"	\
                  CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    set +x
}

clean() {
    rm -rf out
    make -C AnyKernel3 clean
}

case $1 in
    s)
        compile 2>&1> logs.txt
    ;;
    sc)
        clean
        compile 2>&1> logs.txt
    ;;
    c)
        clean
        compile
    ;;
    *)
        compile
    ;;
esac

make -C AnyKernel3 clean

if [ "$?" == 0 ]; then
   cp $(pwd)/out/arch/arm64/boot/Image.gz-dtb $(pwd)/AnyKernel3
   cp $(pwd)/out/arch/arm64/boot/dtbo.img $(pwd)/AnyKernel3
   cd $(pwd)/AnyKernel3
   make -j8
   zipname=$(ls *.zip)
   url=$(curl --upload-file ./${zipname} https://transfer.sh/${zipname})
   echo -e "\nKernel Url:"
   echo "${url}"
   echo -e "\n"
   cd ..
fi
