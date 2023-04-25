#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

RP_TOOLCHAIN_LINK=https://github.com/Pro/raspi-toolchain/releases/latest/download/raspi-toolchain.tar.gz
CMAKE_CONF_LINK=https://raw.githubusercontent.com/Pro/raspi-toolchain/master/Toolchain-rpi.cmake

RP_CROSS_GCC=/opt/cross-pi-gcc
CROSS_COMP_PATH=${RP_CROSS_GCC}/bin:${RP_CROSS_GCC}/libexec/gcc/arm-linux-gnueabihf/8.3.0:

RASP_DIR=/raspberrypi
RFS_DIR=/rootfs
CMAKE_CONF=/Toolchain-rpi.cmake

CMAKE_ROOT_LISTS=/CMakeLists.txt
CMAKE_SRC_LISTS=/src/CMakeLists.txt

TOOLCHAIN_DIR=/toolchain
BUILD_DIR=/build
BIN_DIR=/bin

OPT_TYPE=RelWithDebInfo


if [ ! -f ${ROOT_DIR}${CMAKE_ROOT_LISTS} ]; then
	echo "Create root CmakeLists.txt"

	echo "cmake_minimum_required(VERSION 3.15)" >> ${ROOT_DIR}${CMAKE_ROOT_LISTS}
	echo "project(ARM32-BinarySearch ASM)" >> ${ROOT_DIR}${CMAKE_ROOT_LISTS}
	echo "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \"\${CMAKE_BINARY_DIR}/../bin\")" >> ${ROOT_DIR}${CMAKE_ROOT_LISTS}
	echo "add_subdirectory(src)" >> ${ROOT_DIR}${CMAKE_ROOT_LISTS}
fi

if [ ! -f ${ROOT_DIR}${CMAKE_SRC_LISTS} ]; then
	echo "Create source CmakeLists.txt"

	echo "add_executable(main main.s)" >> ${ROOT_DIR}${CMAKE_SRC_LISTS}
fi

if [ -z "$(ls -A ${HOME}${RASP_DIR}${RFS_DIR})" ]; then	
	echo "Download libaries from target platform"
	echo "Enter your Raspberry Pi password:"

	mkdir -p ${HOME}${RASP_DIR}${RFS_DIR}

	#Specify your own Raspberry Pi address and SSH port
	rsync --rsh='ssh -p5022' -vR --progress -rl --delete-after --safe-links pi@localhost:/{lib,usr,etc/ld.so.conf.d,opt/vc/lib} ${HOME}${RASP_DIR}${RFS_DIR}
fi

if [ ! -f ${HOME}${RASP_DIR}${CMAKE_CONF} ]; then
	echo "Download cmake config file for Raspberry Pi cross compilation"
	
	wget -P ${HOME}${RASP_DIR} ${CMAKE_CONF_LINK}
fi

if [ -z "$(ls -A ${RP_CROSS_GCC})" ]; then
	echo "Install toolchain for Raspberry Pi"

	mkdir -p ${ROOT_DIR}${TOOLCHAIN_DIR}
	wget -P ${ROOT_DIR}${TOOLCHAIN_DIR} ${RP_TOOLCHAIN_LINK}
	sudo tar xfz ${ROOT_DIR}${TOOLCHAIN_DIR}/raspi-toolchain.tar.gz --strip-components=1 -C /opt
fi

if [ -d ${ROOT_DIR}${BIN_DIR} ]; then
	rm -rf ${ROOT_DIR}${BIN_DIR}
fi

if [ -d ${ROOT_DIR}${BUILD_DIR} ]; then
	rm -rf ${ROOT_DIR}${BUILD_DIR}
fi


mkdir -p ${ROOT_DIR}${BUILD_DIR}
cd ${ROOT_DIR}${BUILD_DIR}

export RASPBIAN_ROOTFS=${HOME}${RASP_DIR}${RASP_DIR}
export PATH=${CROSS_COMP_PATH}${PATH}
export RASPBERRY_VERSION=1

echo "Create Makefile"
cmake -DCMAKE_TOOLCHAIN_FILE=${HOME}${RASP_DIR}${CMAKE_CONF} -DCMAKE_BUILD_TYPE=${OPT_TYPE} ${ROOT_DIR}

echo "Compile executable file"
make -j
