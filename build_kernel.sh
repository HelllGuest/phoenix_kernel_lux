#!/bin/bash
#
# Custom build script  Kanged From BB-Kernel and  android_kernel_motorola_msm8916
#
# Credits : KunalKene1797 (Kunal Kene) and sultanqasim (Sultan Khan)
# https://github.com/BlackBox-Kernel/blackbox_sprout_kk/blob/BB-KK/build.sh
# https://github.com/sultanqasim/android_kernel_motorola_msm8916/blob/squid_linux_mr1/build_cwm_zip.sh
#
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#
# Init Script
#
# Color Code Script
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
nocol='\033[0m'         # Default

KERNEL_DIR=$PWD
ZIMAGE=$KERNEL_DIR/arch/arm/boot/zImage
FLASHZIP=$KERNEL_DIR/arch/arm/boot/phoenix_kernel.zip
BUILD_START=$(date +"%s")

# Modify the following variable if you want to build
export KBUILD_BUILD_USER="anoopkumar"
export KBUILD_BUILD_HOST="helllfire"
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/home/anoopkumar/android/toolchains/arm-linux-eabi-UB-4.9/bin/arm-eabi-

compile_kernel ()
{
echo -e "$blue***********************************************"
echo "          Compiling Phoenix kernel         "
echo -e "***********************************************$nocol"
make phoenix_defconfig
make menuconfig
make -j4 zImage
if ! [ -a $ZIMAGE ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}

create_zip ()
{
echo -e "$yellow*************************************************"
echo "             Creating flashable zip"
echo -e "*************************************************$nocol"
make -j4 dtimage
make -j4 modules
rm -rf phoenix_kernel
mkdir -p phoenix_kernel
make -j4 modules_install INSTALL_MOD_PATH=phoenix_kernel INSTALL_MOD_STRIP=1
mkdir -p cwm_flash_zip/system/lib/modules/pronto
find phoenix_kernel/ -name '*.ko' -type f -exec cp '{}' cwm_flash_zip/system/lib/modules/ \;
mv cwm_flash_zip/system/lib/modules/wlan.ko cwm_flash_zip/system/lib/modules/pronto/pronto_wlan.ko
cp arch/arm/boot/zImage cwm_flash_zip/tools/
cp arch/arm/boot/dt.img cwm_flash_zip/tools/
rm -f arch/arm/boot/phoenix_kernel.zip
cd cwm_flash_zip
zip -r ../arch/arm/boot/phoenix_kernel.zip ./
if ! [ -a $FLASHZIP ];
then
echo -e "$redFlashable zip creation failed$nocol"
exit 1
fi
finally_done
}

finally_done ()
{
echo -e "$cyan Flashable zip created on: $FLASHZIP$nocol"
}

case $1 in
make)
compile_kernel
create_zip
;;
clean)
make clean mrproper
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -f cwm_flash_zip/boot.img
rm -rf phoenix_kernel
rm -f arch/arm/boot/phoenix_kernel.zip
rm -f cwm_flash_zip/tools/dt.img
rm -f cwm_flash_zip/tools/zImage
;;
*)
echo -e "$green Add valid option\nValid options are:\n./build_kernel.sh (make|clean)$nocol"
exit 1
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"

