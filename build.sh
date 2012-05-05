#!/bin/bash

OUTDIR="/android/clockworkmod/t1/out"
INITRAMFSDIR="/android/clockworkmod/t1/ramdisk"
TOOLCHAIN="/android/ics/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"
MODULES=("drivers/samsung/j4fs/j4fs.ko" "crypto/ansi_cprng.ko" "drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko")

cd kernel
case "$1" in
	clean)
        make mrproper ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		;;
	*)
        make cyanogenmod_i9100g_defconfig ARCH=arm CROSS_COMPILE=$TOOLCHAIN

        make -j8 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR modules
        
        for module in "${MODULES[@]}" ; do
            cp "$module" $INITRAMFSDIR/lib/modules/
        done
        
        make -j8 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR zImage
        cp arch/arm/boot/zImage ${OUTDIR}
	;;
esac


