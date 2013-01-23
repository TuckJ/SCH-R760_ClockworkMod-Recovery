export CROSS_COMPILE=/opt/toolchains/arm-eabi-4.4.3/bin/arm-eabi-
export ARCH=arm
export USE_SEC_FIPS_MODE=true
make u1_na_uscc_defconfig
make
