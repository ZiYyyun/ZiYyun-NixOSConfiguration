# Embedded Toolchains

Embedded tools are managed as Flake devShells instead of global system packages.
This keeps `nixos-rebuild` smaller and prevents one vendor toolchain from breaking the whole machine.

Reference reading:

- [NixOS & Flakes: Cross Platform Compilation](https://nixos-and-flakes.thiscute.world/zh/development/cross-platform-compilation)

## Entrypoints

MCU/vendor environments:

```bash
nix develop .#stm
nix develop .#esp
nix develop .#nordic
nix develop .#segger
```

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
| Add shared build/flash/serial tools | `dev_toolchains/libs/libs_emb_packages.nix` |
| Add packages for STM/ESP/Nordic | `dev_toolchains/libs/libs_emb_packages.nix`, matching group |
| Add Allwinner-specific tools such as `sunxi-tools` | `dev_toolchains/libs/libs_emb_packages.nix`, group `allwinner` |
| Add Rockchip-specific tools such as `rkdeveloptool` | `dev_toolchains/libs/libs_emb_packages.nix`, group `rockchip` |
| Change shell variables or messages | `dev_toolchains/dev_embedded/<target>.nix` |
| Add a new devShell output | `flake.nix`, `devShells.${system}` |

## Directory Layout

```text
dev_toolchains/
|-- libs/
|   |-- libs_cmp_packages.nix
|   |-- libs_emb_packages.nix
|   |-- libs_cmp_shell.nix
|   |-- libs_emb_mcu_shell.nix
|   `-- libs_emb_linux_cross_shell.nix
|-- dev_compliers/
|   |-- dev_cmp_c-cpp.nix
|   |-- dev_cmp_rust.nix
|   |-- dev_cmp_python.nix
|   |-- dev_cmp_node.nix
|   |-- dev_cmp_go.nix
|   |-- dev_cmp_java.nix
|   `-- dev_cmp_dotnet.nix
`-- dev_embedded/
    |-- dev_emb_stm.nix
    |-- dev_emb_esp.nix
    |-- dev_emb_nordic.nix
    |-- dev_emb_segger.nix
    |-- dev_emb_arm32.nix
    |-- dev_emb_arm64.nix
    |-- dev_emb_allwinner.nix
    `-- dev_emb_rockchip.nix
```

## Current Groups

| Shell | Package focus |
| --- | --- |
| `stm` | `pkgsCross.arm-embedded` toolchain, `openocd`, `stlink`, `stm32flash`, serial tools |
| `esp` | `esptool`, `espflash`, `platformio`, serial tools, common build tools |
| `nordic` | `nrfutil`, `probe-rs-tools`, `openocd`, serial tools |
| `segger` | `steam-run`, `segger-studio`, and `jlink-exe` launchers for manual SEGGER installs |
| `arm32` | ARMv7 Linux cross toolchain, `dtc`, `ubootTools`, image/filesystem tools, NXP `uuu` |
| `arm64` | ARM64 Linux cross toolchain, `dtc`, `ubootTools`, image/filesystem tools |
| `allwinner` | ARMv7 Linux cross toolchain plus `sunxi-tools` |
| `rockchip` | ARM64 Linux cross toolchain plus `rkdeveloptool`, `rkflashtool`, `rkbin`, `rkboot` |

Nordic intentionally does not include `nrf-command-line-tools` right now because that path can pull an obsolete Qt4/J-Link dependency and break evaluation. Add it only after handling that package explicitly.

## SEGGER Embedded Studio

`segger-jlink` exists in nixpkgs, but the full package pulls bundled Qt4 GUI
libraries and is marked insecure. Headless mode avoids Qt4 but also omits the
usual `JLinkExe` command. This repository therefore does not install
`segger-jlink` from nixpkgs by default.

Use the SEGGER shell as a wrapper around manual SEGGER installs:

```bash
nix develop .#segger
segger-studio
jlink-exe
```

The shell searches these paths:

```text
$SEGGER_STUDIO_HOME/bin/emStudio
$HOME/SEGGER/EmbeddedStudio/bin/emStudio
$HOME/SEGGER/SEGGER Embedded Studio/bin/emStudio
/opt/SEGGER/SEGGER Embedded Studio for ARM/bin/emStudio
/opt/SEGGER/EmbeddedStudio/bin/emStudio
```

`jlink-exe` searches these paths:

```text
$SEGGER_JLINK_HOME/JLinkExe
$SEGGER_JLINK_HOME/bin/JLinkExe
$HOME/SEGGER/JLink/JLinkExe
/opt/SEGGER/JLink/JLinkExe
```

If your install is elsewhere:

```bash
export SEGGER_STUDIO_HOME="/path/to/SEGGER Embedded Studio for ARM"
nix develop .#segger
segger-studio
```

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

The reason is practical: when a single source file is opened, copied, logged by a build system, or shown in an error message, the prefix still tells you which layer owns it. The same rule is used in this repository's toolchain helpers: target files use `dev_cmp_*` or `dev_emb_*`, while shared helper files under `dev_toolchains/libs/` use `libs_*`.
