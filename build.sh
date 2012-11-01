#!/bin/bash

# modify
TOOLCHAIN="/android/ics/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"

# don't modify
CWM_VERSION="6.0.1.2"
OUTDIR="out"
INITRAMFS_SOURCE="../stage1/initramfs.list"
INITRAMFS_ANDROID="ramdisk_android"
INITRAMFS_RECOVERY="ramdisk_recovery"
MODULES=("fs/cifs/cifs.ko" "drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko" "crypto/ansi_cprng.ko" "drivers/samsung/j4fs/j4fs.ko")

case "$1" in
	clean)
        cd kernel
        make mrproper ARCH=arm CROSS_COMPILE=${TOOLCHAIN}
        cd ..

        rm stage1/files/boot.cpio
        rm stage1/files/recovery.cpio
        rm -rf ${OUTDIR}
		;;
	*)
		mkdir -p ${OUTDIR}
        cd kernel
        make clockworkmod_i9100g_defconfig ARCH=arm CROSS_COMPILE=${TOOLCHAIN}

        # build modules first to include them into android ramdisk
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} modules
       
        for module in "${MODULES[@]}" ; do
            cp "${module}" ../${INITRAMFS_ANDROID}/lib/modules/
        done
        cd ..

        # create the android ramdisk
        cd ${INITRAMFS_ANDROID}
        find . | cpio -o -H newc > ../stage1/files/boot.cpio
        cd ..

        # create the recovery ramdisk
        cd ${INITRAMFS_RECOVERY}
        find . | cpio -o -H newc > ../stage1/files/recovery.cpio
        cd ..
        
        # build the zimage
        cd kernel
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} CONFIG_INITRAMFS_SOURCE=${INITRAMFS_SOURCE} zImage
        cp arch/arm/boot/zImage ../${OUTDIR}
        cd ../${OUTDIR}
        tar -cf GT-I9100G_ICS_ClockworkMod-Recovery_${CWM_VERSION}.tar zImage
        cd ..
	    ;;
esac
