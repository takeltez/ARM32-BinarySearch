#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ON_TARGET_BUILD_DIR=/on-target
CROSS_COMP_DIR=/cross-comp
TOOLCHAIN_DIR=/toolchain
TARGET_DIR=/target
BUILD_DIR=/build
BIN_DIR=/bin
SRC_DIR=/src

EXEC_FILE=bin_search

CMAKE_LANG=ASM
COMP_TYPE=gcc
SRC_EXT=.s

CMAKE_LIST=/CMakeLists.txt
MAKE_FILE=/Makefile

CROSS_COMP=/opt/cross-pi-gcc
CROSS_COMP_ARCH=/raspi-toolchain.tar.gz
CROSS_COMP_PATH=${CROSS_COMP}/bin:${CROSS_COMP}/libexec/gcc/arm-linux-gnueabihf/8.3.0:

RASP_DIR=/raspberrypi
RFS_DIR=/rootfs
CMAKE_CONF=/Toolchain-rpi.cmake

OPT_TYPE=RelWithDebInfo

function cross_comp()
{
	echo "|-------------------|"
	echo "| CROSS-COMPILATION |"
	echo "|-------------------|"

	if [ -d ${ROOT_DIR}${TARGET_DIR}${CROSS_COMP_DIR} ]; then
		rm -rf ${ROOT_DIR}${TARGET_DIR}${CROSS_COMP_DIR}
	fi

	if [ -d ${ROOT_DIR}${BUILD_DIR} ]; then
		rm -rf ${ROOT_DIR}${BUILD_DIR}
	fi

	if [ ! -f ${ROOT_DIR}${CMAKE_LIST} ]; then
		echo "*****"
		echo "Genetate CmakeLists.txt in ${ROOT_DIR}"

		echo -e "cmake_minimum_required(VERSION 3.15)\n" >> ${ROOT_DIR}${CMAKE_LIST}
		echo -e "project(ARM32-BinarySearch ${CMAKE_LANG})\n" >> ${ROOT_DIR}${CMAKE_LIST}
		echo -e "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \"\${PROJECT_SOURCE_DIR}${TARGET_DIR}${CROSS_COMP_DIR}${BIN_DIR}\")\n" >> ${ROOT_DIR}${CMAKE_LIST}
		echo -e "add_subdirectory(src)" >> ${ROOT_DIR}${CMAKE_LIST}
	fi

	if [ ! -f ${ROOT_DIR}${SRC_DIR}${CMAKE_LIST} ]; then
		echo "Genetate CmakeLists.txt in ${ROOT_DIR}${SRC_DIR}"
		echo "*****"

		echo -e "file(GLOB SRC_LIST \${CMAKE_CURRENT_SOURCE_DIR}/*${SRC_EXT})\n" >> ${ROOT_DIR}${SRC_DIR}${CMAKE_LIST}
		echo -e "include_directories(\${CMAKE_CURRENT_SOURCE_DIR})\n" >> ${ROOT_DIR}${SRC_DIR}${CMAKE_LIST}
		echo -e "add_executable(${EXEC_FILE} \${SRC_LIST})" >> ${ROOT_DIR}${SRC_DIR}${CMAKE_LIST}
	fi

	if [ -z "$(ls -A ${CROSS_COMP})" ]; then
		echo "*****"
		echo "Extract toolchain from ${ROOT_DIR}${TOOLCHAIN_DIR}${CROSS_COMP_ARCH} in ${CROSS_COMP}"
		echo "*****"

		sudo tar xfz ${ROOT_DIR}${TOOLCHAIN_DIR}${CROSS_COMP_ARCH} --strip-components=1 -C /opt

		if [ "$?" -ne "0" ]; then
			echo "*****"
			echo "Extraction failed!"
			echo "*****"
			exit 1
		fi
	fi

	if [ -z "$(ls -A ${ROOT_DIR}${RASP_DIR}${RFS_DIR})" ]; then
		mkdir -p ${ROOT_DIR}${RASP_DIR}${RFS_DIR}

		echo "*****"
		echo "Download dependencies from $1:$2 in ${ROOT_DIR}${RASP_DIR}${RFS_DIR}"
		echo "*****"

		rsync --rsh='ssh -p'"$2" -vR --progress -rl --delete-after --safe-links "$1":/{lib,usr,etc/ld.so.conf.d,opt/vc/lib} ${ROOT_DIR}${RASP_DIR}${RFS_DIR}

		if [ $? -ne 0 ]; then
			echo "*****"
			echo "Download failed!"
			echo "*****"
			exit 1
		fi
	fi

	mkdir -p ${ROOT_DIR}${TARGET_DIR}${CROSS_COMP_DIR}${BIN_DIR}
	mkdir -p ${ROOT_DIR}${BUILD_DIR}

	cd ${ROOT_DIR}${BUILD_DIR}

	export RASPBIAN_ROOTFS=${ROOT_DIR}${RASP_DIR}${RASP_DIR}
	export PATH=${CROSS_COMP_PATH}${PATH}
	export RASPBERRY_VERSION=1

	echo "*****"
	echo "Gnererate Makefile in ${ROOT_DIR}${BUILD_DIR}"
	echo "*****"

	cmake -DCMAKE_TOOLCHAIN_FILE=${ROOT_DIR}${TOOLCHAIN_DIR}${CMAKE_CONF} -DCMAKE_BUILD_TYPE=${OPT_TYPE} ${ROOT_DIR}

	echo "*****"
	echo "Compile executable file in ${ROOT_DIR}${TARGET_DIR}${CROSS_COMP_DIR}${BIN_DIR}"
	echo "*****"

	make -j

}

function on_target()
{
	echo "|-----------|"
	echo "| ON-TARGET |"
	echo "|-----------|"

	if [ -d ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR} ]; then
		rm -rf ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}
	fi

	mkdir -p ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${SRC_DIR}

	echo "*****"
	echo "Copy sources from ${ROOT_DIR}${SRC_DIR} in ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${SRC_DIR}"

	cp ${ROOT_DIR}${SRC_DIR}/*${SRC_EXT} ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${SRC_DIR}

	if [ $? -ne 0 ]; then
		echo "*****"
		echo "Copy failed!"
		echo "*****"
		exit 1
	fi

	echo "Genetate Makefile in ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}"
	echo "*****"

	echo -e "TARGET = ${EXEC_FILE}\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "CC = ${COMP_TYPE}\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "PREF_SRC = src/\nPREF_OBJ = build/\nPREF_BIN = bin/\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "SRC = \$(wildcard \$(PREF_SRC)*${SRC_EXT})" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "OBJ = \$(patsubst \$(PREF_SRC)%${SRC_EXT}, \$(PREF_OBJ)%.o, \$(SRC))\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e ".PHONY: all install dir rdir clean\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "all: dir \$(TARGET) install\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\$(TARGET): \$(OBJ)" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\t\$(CC) \$(OBJ) -o \$(TARGET)\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\$(PREF_OBJ)%.o: \$(PREF_SRC)%${SRC_EXT}" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\t\$(CC) -c $< -o \$@ -I\$(PREF_SRC)\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "install:" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\tinstall \$(TARGET) \$(PREF_BIN)\n\trm -f \$(TARGET)\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "dir:" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\tmkdir -p \$(PREF_BIN)\n\tmkdir -p \$(PREF_OBJ)\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "rdir:" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\trm -rf \$(PREF_BIN)\n\trm -rf \$(PREF_OBJ)\n" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "clean:" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
	echo -e "\trm -f \$(PREF_BIN)\$(TARGET)\n\trm -f \$(PREF_OBJ)*.o" >> ${ROOT_DIR}${TARGET_DIR}${ON_TARGET_BUILD_DIR}${MAKE_FILE}
}

if [ "$1" == "cross-comp" ]; then
	cross_comp $2 $3
elif [ "$1" == "on-target" ]; then
	on_target
else
	echo -e "./build.sh [build-type] [host@ip] [port]"
	echo -e "\nbuild-type:"
	echo -e "\tcross-comp - cross-compilation for target device"
	echo -e "\t\thost@ip - address of target device"
	echo -e "\t\tport - ssh port of target"
	echo -e "\ton-target - provide directory includes sources and Makefile for build project on target device (address and port options are ignored)"
fi

exit 0
