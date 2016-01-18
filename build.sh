#!/bin/bash
#
# Custom build script  Kanged From thunderzap_tomato and  android_kernel_motorola_msm8916
#
# Credits : varunchitre15 (Varun Chitre) and sultanqasim (Sultan Khan)
# https://github.com/varunchitre15/thunderzap_tomato/blob/cm-12.1/build.sh
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
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE="/home/anoopkumar/android/toolchains/armeb-cortex_a53-linux-gnueabi/bin/armeb-cortex_a53-linux-gnueabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="anoopkumar"
export KBUILD_BUILD_HOST="helllfire"


compile_kernel ()
{
echo -e "$yellow***********************************************"
echo "          Compiling Phoenix kernel          "
echo -e "***********************************************$nocol"
rm -f $KERN_IMG
make phoenix_defconfig
make zImage -j4
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
make dtimage -j4
make modules -j4
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
make_zip
}

make_zip ()
{
echo "Copying modules"
mkdir -p phoenix_kernel
make -j4 modules_install INSTALL_MOD_PATH=phoenix_kernel INSTALL_MOD_STRIP=1
mkdir -p cwm_flash_zip/system/lib/modules/pronto
find phoenix_kernel/ -name '*.ko' -type f -exec cp '{}' cwm_flash_zip/system/lib/modules/ \;
mv cwm_flash_zip/system/lib/modules/wlan.ko cwm_flash_zip/system/lib/modules/pronto/pronto_wlan.ko
cp arch/arm/boot/zImage cwm_flash_zip/tools/
cp arch/arm/boot/dt.img cwm_flash_zip/tools/
rm -f arch/arm/boot/phoenix_kernel.zip
cd cwm_flash_zip
zip -r --exclude=*.gitignore* ../arch/arm/boot/phoenix_kernel.zip ./
cd $KERNEL_DIR
}

case $1 in
clean)
echo -e "$cyan***********************************************"
echo "          Cleaning          "
echo -e "***********************************************$nocol"
make ARCH=arm -j4 clean mrproper
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -rf phoenix_kernel
rm -f arch/arm/boot/phoenix_kernel.zip
rm -f cwm_flash_zip/tools/dt.img
rm -f cwm_flash_zip/tools/zImage
;;
dt)
make phoenix_defconfig
make dtimage -j4
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
;;
*)
compile_kernel
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
