#!/bin/bash

# modify
TOOLCHAIN="/opt/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"

# don't modify
CWM_VERSION="6.0.1.2"
OUTDIR="out"
INITRAMFS_SOURCE="../stage1/initramfs.list"
INITRAMFS_ANDROID="ramdisk_android"
INITRAMFS_RECOVERY="ramdisk_recovery"
MODULES=("drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko" "drivers/samsung/j4fs/j4fs.ko" "drivers/staging/westbridge/astoria/switch/cyasswitch.ko")

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
	export USE_SEC_FIPS_MODE=true
        make u1_na_uscc_defconfig ARCH=arm CROSS_COMPILE=${TOOLCHAIN}

        # build modules first to include them into android ramdisk
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} modules

	#strip modules
	find . -type f -name '*.ko' | xargs -n 1 /opt/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-strip --strip-unneeded
       
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
        tar -cf SCH-R760_ICS_ClockworkMod-Recovery_${CWM_VERSION}.tar zImage
        md5sum -t SCH-R760_ICS_ClockworkMod-Recovery_${CWM_VERSION}.tar >> SCH-R760_ICS_ClockworkMod-Recovery_${CWM_VERSION}.tar
        mv SCH-R760_ICS_ClockworkMod-Recovery_${CWM_VERSION}.tar SCH-R760_ICS_ClockworkMod-Recovery_${CWM_VERSION}.tar.md5
        cd ..
	    ;;
esac
