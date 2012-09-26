#!/bin/sh

CPU_COUNT=`grep 'processor' /proc/cpuinfo | wc -l`
TOOLCHAIN=$HOME/dev/arm-2010q1/bin
TOOLCHAIN_PREFIX=arm-none-eabi-

# setup config file version
sed -i s/CONFIG_LOCALVERSION=\"-ic3man5-.*\"/CONFIG_LOCALVERSION=\"-ic3man5-${2}AOSP\"/ .config

#compile the kernel unless --skip-build is specified.
if [ "$1" != "--skip-build" ]; then
	make -j$CPU_COUNT ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX
	if [ $? -ne 0 ]; then
		echo -ne "\n\nWARNING: Build failed, stopping...\n\n"
		exit;
	fi

	# clean up modules a bit
	find . -name "*.ko" | xargs $TOOLCHAIN/${TOOLCHAIN_PREFIX}strip --strip-unneeded

	# Move modules.
	find . -name "*.ko" -exec cp "{}" ./modules/ \;
	echo "Modules have been moved to ./modules/"
fi

read -p "Would you like to create a boot.img file (requires phone/adb) (y/n)? " answer
if [ "$answer" = "y" ]; then
	./create_boot_img.sh
fi

read -p "Would you like to create flashable zip file (y/n)? " answer
if [ "$answer" = "y" ]; then
	cd zip_file
	./update_zip
	cd ..
fi
