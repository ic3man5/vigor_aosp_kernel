#!/bin/sh

PTOOLS_DIR=~/dev/android-sdk-linux/platform-tools

device_present=`${PTOOLS_DIR}/adb devices |grep recovery | cut -f 1 - `

if [ "$device_present" != "HT1AWS202235" ]; then
	echo "We are not in recovery, rebooting now..."
	${PTOOLS_DIR}/adb reboot recovery
	sleep 3
fi

while [ "$device_present" != "HT1AWS202235" ]; do
	echo "Waiting for device..."
	sleep 2
	device_present=`${PTOOLS_DIR}/adb devices |grep recovery | cut -f 1 - `
done

${PTOOLS_DIR}/adb shell mkdir /sdcard/tmp
${PTOOLS_DIR}/adb shell dd if=/dev/block/mmcblk0p22 of=/sdcard/tmp/boot.img
${PTOOLS_DIR}/adb push ./arch/arm/boot/zImage /sdcard/tmp/zImage
${PTOOLS_DIR}/adb push ./abootimg /sdcard/tmp/abootimg
#${PTOOLS_DIR}/adb shell chmod +x /sdcard/tmp/abootimg
${PTOOLS_DIR}/adb shell /sdcard/tmp/abootimg -u /sdcard/tmp/boot.img -k /sdcard/tmp/zImage
rm ./boot.img >> /dev/null
${PTOOLS_DIR}/adb pull /sdcard/tmp/boot.img ./boot.img
