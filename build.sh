#!/bin/sh

CPU_COUNT=`grep 'processor' /proc/cpuinfo | wc -l`
TOOLCHAIN=$HOME/dev/arm-2010q1/bin
TOOLCHAIN_PREFIX=arm-none-eabi-

# setup config file version
sed -i s/CONFIG_LOCALVERSION=\"-ic3man5-.*\"/CONFIG_LOCALVERSION=\"-ic3man5-${2}AOSP\"/ .config

#compile the kernel
make -j$CPU_COUNT ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX
if [ $? -ne 0 ]; then
	echo -ne "\n\nWARNING: Build failed, stopping...\n\n"
	exit;
fi

# clean up modules a bit
find . -name "*.ko" | xargs $TOOLCHAIN/${TOOLCHAIN_PREFIX}strip --strip-unneeded

find . -name "*.ko" -exec cp "{}" ./modules/ \;
echo "Modules have been moved to ./modules/"
