# Embedded Toolchains

Embedded compiler, flashing, debug, and cross-compilation tools are managed as
Flake devShells instead of global system packages. GUI IDEs should stay as
system applications or manual vendor installs unless they can be packaged cleanly.

Reference reading:

- [NixOS & Flakes: Cross Platform Compilation](https://nixos-and-flakes.thiscute.world/zh/development/cross-platform-compilation)

## Entrypoints

MCU/vendor environments:

```bash
nix develop .#stm
nix develop .#esp          # unified ESP32 shell: ESP-IDF + flashing/serial tools
nix develop .#esp-idf      # same shell as .#esp (alias)
nix develop .#nordic
nix develop .#segger
```

The `esp` shell merges the ESP-IDF framework (from
[mirrexagon/nixpkgs-esp-dev](https://github.com/mirrexagon/nixpkgs-esp-dev),
see the [NixOS Wiki ESP-IDF page](https://wiki.nixos.org/wiki/ESP-IDF)) with the
old flashing/serial tools: `idf.py`, `esptool`, `espflash`, `platformio`,
`openocd`, `probe-rs`. It is built against nixpkgs 25.11 (`nixpkgs-esp`
input), because esp-dev needs `python310` which 26.05 dropped. The Espressif
VSCode extension only supports Debian/Ubuntu; on NixOS run `idf.py` from a
terminal inside the shell (direnv handles this in VSCode).

Linux SoC / cross-compilation environments:

```bash
nix develop .#arm32
nix develop .#arm64
nix develop .#allwinner
nix develop .#rockchip
```

## Where To Edit

| Need | File |
| --- | --- |
| Add shared build/flash/serial tools | `dev_toolchains/libs/embedded-packages.nix` |
| Add packages for STM/ESP/Nordic | `dev_toolchains/libs/embedded-packages.nix`, matching group |
| Add Allwinner-specific tools such as `sunxi-tools` | `dev_toolchains/libs/embedded-packages.nix`, group `allwinner` |
| Add Rockchip-specific tools such as `rkdeveloptool` | `dev_toolchains/libs/embedded-packages.nix`, group `rockchip` |
| Change shell variables or messages | `dev_toolchains/embedded/<target>.nix` |
| Add a new devShell output | `flake.nix`, `devShells.${system}` |

## Directory Layout

```text
dev_toolchains/
|-- libs/
|   |-- compiler-packages.nix
|   |-- embedded-packages.nix
|   |-- compiler-shell.nix
|   |-- embedded-mcu-shell.nix
|   `-- embedded-linux-cross-shell.nix
|-- compilers/
|   |-- c-cpp.nix
|   |-- rust.nix
|   |-- python.nix
|   |-- node.nix
|   |-- go.nix
|   |-- java.nix
|   `-- dotnet.nix
`-- embedded/
    |-- stm.nix
    |-- esp.nix
    |-- nordic.nix
    |-- segger.nix
    |-- arm32.nix
    |-- arm64.nix
    |-- allwinner.nix
    `-- rockchip.nix
```

## Current Groups

| Shell | Package focus |
| --- | --- |
| `stm` | `pkgsCross.arm-embedded` toolchain, `openocd`, `stlink`, `stm32flash`, serial tools |
| `esp` | `esptool`, `espflash`, `platformio`, serial tools, common build tools |
| `nordic` | `nrfutil`, `probe-rs-tools`, `openocd`, serial tools |
| `segger` | `steam-run` and `jlink-exe` launcher for manual SEGGER J-Link installs |
| `arm32` | ARMv7 Linux cross toolchain, `dtc`, `ubootTools`, image/filesystem tools, NXP `uuu` |
| `arm64` | ARM64 Linux cross toolchain, `dtc`, `ubootTools`, image/filesystem tools |
| `allwinner` | ARMv7 Linux cross toolchain plus `sunxi-tools` |
| `rockchip` | ARM64 Linux cross toolchain plus `rkdeveloptool`, `rkflashtool`, `rkbin`, `rkboot` |

Nordic intentionally does not include `nrf-command-line-tools` right now because that path can pull an obsolete Qt4/J-Link dependency and break evaluation. Add it only after handling that package explicitly.

## SEGGER Tools

`segger-jlink` exists in nixpkgs, but the full package pulls bundled Qt4 GUI
libraries and is marked insecure. Headless mode avoids Qt4 but also omits the
usual `JLinkExe` command. This repository therefore does not install
`segger-jlink` from nixpkgs by default.

Use the SEGGER shell only for J-Link helper commands:

```bash
nix develop .#segger
jlink-exe
```

`jlink-exe` searches these paths:

```text
$SEGGER_JLINK_HOME/JLinkExe
$SEGGER_JLINK_HOME/bin/JLinkExe
$HOME/SEGGER/JLink/JLinkExe
/opt/SEGGER/JLink/JLinkExe
```

SEGGER Embedded Studio is intentionally not exposed through `nix develop
.#segger`. The official Linux download is license-gated and installer-based, so
it is not treated as a normal devShell tool in this repository.

## Target Granularity

Use vendor/platform family shells, not chip-model shells:

```bash
nix develop .#stm
nix develop .#esp
nix develop .#arm32
```

Examples:

- STM32C8T6 and STM32F407 both start from `.#stm`
- ESP32, ESP32-S3, and ESP32-C3 start from `.#esp`
- nRF52, nRF53, and nRF91 start from `.#nordic`
- i.MX6ULL starts from `.#arm32`
- Allwinner boards start from `.#allwinner`
- RK3568/RK3588 boards start from `.#rockchip`

Board-specific OpenOCD cfg files, CMake toolchain files, linker scripts, kernel configs, U-Boot configs, and SDK versions should live in each project repo.

## Source File Naming

Project source files should keep their module ownership visible in the file name.
For example, do this:

```text
Interface/Inf_uart.c
Interface/Inf_uart.h
Driver/Drv_gpio.c
Driver/Drv_gpio.h
Application/App_main.c
```

Do not rely only on the directory name:

```text
Interface/uart.c
Driver/gpio.c
```

The reason is practical: when a single source file is opened, copied, logged by a build system, or shown in an error message, the prefix still tells you which layer owns it. The same rule is used in this repository's toolchain helpers: target files use `compiler files` or `embedded files`, while shared helper files under `dev_toolchains/libs/` use `shared helper files`.
