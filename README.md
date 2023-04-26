# Bibary search algorithm for 32-bit ARM platform <br> with cross-compilation for Raspberry Pi

## How to run project
`./build.sh` provides two types of project build:

	./build.sh [build-type] [host@ip] [port]

	build-type:
		cross-comp - cross-compilation for target device
			host@ip - address of target device
			port - ssh port of target
		on-target - provide directory includes sources and Makefile for build project on target device (address and port options are ignored)

### `cross-comp`

#### Pre-requirements
- Raspbery Pi is running
- Raspbery Pi is connected to LAN
- Raspbery Pi is available from host machine

Use of `./build.sh` with `cross-comp` option generates all necessary `CMakeLists.txt` in `root` and `src` directories, extracts
[raspi-toolchain.tar.gz](https://github.com/Pro/raspi-toolchain/releases/tag/v1.0.2 "raspi-toolchain") from `toolchain` directory in `/opt/cross-pi-gcc`, downloads all necessary dependencies from `host@ip` via ssh `port` in `raspberrypi/rootfs` and compiles executable file in `target/cross-comp/bin`.

**Note**: `CmakeLists.txt`, `raspi-toolchain.tar.gz` and `target dependencies` will be installed only in case its absence.

#### From root directory
	#run cross-compilation
	./build.sh cross-comp [host@ip] [port]

	#transmit executalble file on target device
	scp -P [port] target/cross-comp/bin/bin_search [host@ip:path]

Run `bin_search` file on target device.

### `on-target`

#### Pre-requirements
##### Raspbery Pi has:
- GCC Compiler

Use of `./build.sh` with `on-target` option copies all sources from `src` to `target/on-target/src` directory and provides `Makefile` in `target/on-target` directory.

#### From root directory
	#run on-target build
	./build.sh on-target

	#transmit generated directory with Makefile on target device
	scp -P [port] -r target/on-target/src [host@ip:path]
	scp -P [port] target/on-target/Makefile [host@ip:path]

Run `make` on target device, once compilation is finished run `bin_search` file.
