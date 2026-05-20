#!/bin/bash

KERNEL_ROOT="${GITHUB_WORKSPACE:-$(pwd)}"

KERNEL_OUTPUT=$KERNEL_ROOT/out/arch/arm64/boot

# ARCH
export ARCH=arm64
export SUBARCH=arm64

# AnyKernel
AK3_PATH=$KERNEL_ROOT/anykernel
CUSTOM_AK3_NAME=BPF-5.10-BT-Mod
FULL_AK3_NAME=$CUSTOM_AK3_NAME-$(date +%Y-%m-%d)

if [ ! -d "$AK3_PATH" ]; then
    git clone --depth=1 -b realme-sm8250 https://github.com/xxtvrxx233/AnyKernel3.git $AK3_PATH
fi

# Clean existing anykernel packages
if find $AK3_PATH -maxdepth 1 -type f -name "*.zip" | grep -q .; then
    find $AK3_PATH -maxdepth 1 -type f -name "*.zip" -delete
fi

# Clang Toolchain Logic
if [ ! -d "$KERNEL_ROOT/zyc-clang-16/bin" ]; then
    echo "Clang not found or cache missed, downloading..."
    if [ ! -f "/tmp/Clang-16.0.6-20250721.tar.gz" ]; then
        wget -O /tmp/Clang-16.0.6-20250721.tar.gz https://github.com/ZyCromerZ/Clang/releases/download/16.0.6-20250721-release/Clang-16.0.6-20250721.tar.gz
    fi
    mkdir -p "$KERNEL_ROOT/zyc-clang-16"
    tar -xvf /tmp/Clang-16.0.6-20250721.tar.gz -C "$KERNEL_ROOT/zyc-clang-16"
else
    echo "Clang toolchain restored from cache!"
fi

export CLANG_PATH=$KERNEL_ROOT/zyc-clang-16/bin
export PATH="$CLANG_PATH:$PATH"
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

KERNEL_DEFCONFIG="vendor/kona-perf_defconfig"


echo
echo "Kernel is going to be built using $KERNEL_DEFCONFIG"
echo

echo "=== KERNEL CONFIGURATION LOG ===" > "$KERNEL_ROOT/build.log"
make CC="ccache clang" AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LLVM=1 LLVM_IAS=1 O=out $KERNEL_DEFCONFIG 2>&1 | tee -a "$KERNEL_ROOT/build.log"

echo "=== KERNEL COMPILATION LOG ===" >> "$KERNEL_ROOT/build.log"
make CC="ccache clang" AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LLVM=1 LLVM_IAS=1 O=out -j$(nproc --all) 2>&1 | tee -a "$KERNEL_ROOT/build.log"

echo "Build complete"

ccache -s

if [ -f "$KERNEL_OUTPUT/dtb" ] && [ -f "$KERNEL_OUTPUT/dtbo.img" ] && [ -f "$KERNEL_OUTPUT/Image" ]; then
    cd $AK3_PATH
    cp "$KERNEL_OUTPUT/dtb"   .
    cp "$KERNEL_OUTPUT/dtbo.img"  .
    cp "$KERNEL_OUTPUT/Image"     .
    zip -r "$FULL_AK3_NAME.zip" *
    cd $KERNEL_ROOT

    echo "out: $AK3_PATH/$FULL_AK3_NAME.zip"

    # Clean existing 
    rm -f "$AK3_PATH/dtb"
    rm -f "$AK3_PATH/dtbo.img"
    rm -f "$AK3_PATH/Image"
fi
