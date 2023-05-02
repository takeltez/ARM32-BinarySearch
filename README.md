# ARM32-BinarySearch

## About
Binary search algorithm for 32-bit ARM platform with cross-compilation for Raspberry Pi.

## How to start
<details>
<summary>build.sh</summary>

	./build.sh [build-type] [host@ip] [port]

	build-type:
		cross-comp - cross-compilation for target device
			host@ip - address of target device
			port - ssh port of target device
		on-target - provide directory includes sources and Makefile for build project on target device (address and port options are ignored)
</details>

<details>
<summary>cross-comp</summary>

#### Pre-requirements

##### Host device
- GNU make
- CMake

##### Target device
- Raspberry Pi is running
- Raspberry Pi is connected to LAN
- Raspberry Pi is available from host machine

Use of `./build.sh` with `cross-comp` option generates all necessary `CMakeLists.txt` in `root` and `src` directories, extracts
[raspi-toolchain.tar.gz](https://github.com/Pro/raspi-toolchain/releases/tag/v1.0.2 "raspi-toolchain") from `toolchain` directory in `/opt/cross-pi-gcc`, downloads all necessary dependencies from `host@ip` via ssh `port` in `raspberrypi/rootfs` and compiles executable file in `target/cross-comp/bin`.

**Note**: `CmakeLists.txt`, `raspi-toolchain.tar.gz` and `target dependencies` will be installed only in case its absence.

From `ARM32-BinarySearch` directory on host device:

	#run cross-compilation
	./build.sh cross-comp [host@ip] [port]

	#transmit generated directory on target device
	scp -P [port] target/cross-comp [host@ip:path]

Run `bin_search` file on target device.
</details>

<details>
<summary>on-target</summary>

#### Pre-requirements

##### Target device
- GCC Compiler
- GNU Make

Use of `./build.sh` with `on-target` option copies all sources from `src` to `target/on-target/src` directory and provides `Makefile` in `target/on-target` directory.

From `ARM32-BinarySearch` directory on host device:

	#run on-target build
	./build.sh on-target

	#transmit generated directory on target device
	scp -P [port] -r target/on-target [host@ip:path]

Run `make` on target device, once compilation is finished run `bin_search` file.
</details>

## Usage

From `cross-comp` / `on-target` directories on target device:

<details>
<summary>$ ./bin/bin_search</summary>
<br>

	Array must be sorted in ascending order!

	Array size: 5

	Array[0]: 1
	Array[1]: 2
	Array[2]: 3
	Array[3]: 4
	Array[4]: 5

	Found element: 2

	Array[1] = 2
</details>

<details>
<summary>$ ./bin/bin_search</summary>
<br>

	Array must be sorted in ascending order!

	Array size: 5

	Array[0]: 1
	Array[1]: 2
	Array[2]: 3
	Array[3]: 4
	Array[4]: 5

	Found element: 12

	Element 12 not found
</details>
