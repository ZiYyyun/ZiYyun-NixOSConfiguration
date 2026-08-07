# 嵌入式 DevShells

本仓库把嵌入式开发环境统一放进 Flake `devShells`。入口粒度按“厂家/平台族”划分，而不是按具体芯片型号划分。

参考阅读：

- [NixOS 与 Flakes：交叉平台编译](https://nixos-and-flakes.thiscute.world/zh/development/cross-platform-compilation)

## 当前入口

MCU 厂商环境：

```bash
nix develop .#stm
nix develop .#esp
nix develop .#nordic
```

Linux SoC / 交叉编译环境：

```bash
nix develop .#arm32
nix develop .#arm64
nix develop .#allwinner
nix develop .#rockchip
```

默认 shell 目前指向通用 C 开发环境：

```bash
nix develop
```

嵌入式环境请显式选择 `.#stm`、`.#esp`、`.#arm32` 等入口。

## 为什么不按芯片型号拆

不要这样：

```bash
nix develop .#<specific-chip-model>
```

这种粒度太细，会把 shell 目录变成芯片型号仓库。更实用的粒度是：

```bash
nix develop .#stm
```

进入 `stm` 后，再由项目自己的 Makefile、CMake toolchain file、OpenOCD cfg、CubeMX 工程或 linker script 决定具体芯片。

同理：

- ESP32、ESP32-S3、ESP32-C3 先统一进 `.#esp`
- nRF52、nRF53、nRF91 先统一进 `.#nordic`
- i.MX6ULL 归入 `.#arm32`
- Allwinner/全志系列用 `.#allwinner`，环境内包含 `sunxi-tools`
- RK3568/RK3588 等归入 `.#rockchip`

## 目录结构

```text
shells/
├── lib/
│   ├── packages.nix              # 可复用包组
│   ├── mk-mcu-shell.nix          # MCU shell 生成器
│   └── mk-linux-cross-shell.nix  # Linux SoC 交叉编译 shell 生成器
├── languages/
│   ├── c.nix
│   ├── cpp.nix
│   ├── rust.nix
│   ├── python.nix
│   ├── node.nix
│   ├── go.nix
│   ├── java.nix
│   └── dotnet.nix
└── embedded/
    ├── stm.nix
    ├── esp.nix
    ├── nordic.nix
    ├── arm32.nix
    ├── arm64.nix
    ├── allwinner.nix
    └── rockchip.nix
```

## 设计思路

核心原则是：通用包只写一次，具体目标只组合。

| 层级 | 作用 |
|---|---|
| `shells/lib/packages.nix` | 定义可复用包组，比如 `buildCore`、`debugAndFlash`、`serialTools`、`stm`、`esp`、`nordic`、`linuxSocCommon` |
| `shells/lib/mk-mcu-shell.nix` | 生成 MCU 环境，适合 STM、ESP、Nordic 这类主要需要构建、烧录、调试工具的目标 |
| `shells/lib/mk-linux-cross-shell.nix` | 生成 Linux SoC 交叉编译环境，会导出 `ARCH` 和 `CROSS_COMPILE` |
| `shells/embedded/*.nix` | 每个厂家/平台族自己的薄配置文件 |

## 交叉编译工具链怎么引入

Linux SoC shell 使用 `pkgs.pkgsCross`，不是手动到处 `import <nixpkgs>`。

例如 ARM32：

```nix
crossPkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
arch = "arm";
```

ARM64：

```nix
crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
arch = "arm64";
```

`mk-linux-cross-shell.nix` 会把交叉工具链加入 shell，并自动导出：

```bash
ARCH=arm
CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
```

或 ARM64：

```bash
ARCH=arm64
CROSS_COMPILE=aarch64-unknown-linux-gnu-
```

具体前缀以 nixpkgs 当前工具链为准，进入 shell 时会打印出来。

## 当前包组

| Shell | 包组重点 |
|---|---|
| `stm` | `pkgsCross.arm-embedded` 工具链、`openocd`、`stlink`、`stm32flash`、串口工具 |
| `esp` | `esptool`、`espflash`、`platformio`、串口工具、基础构建工具 |
| `nordic` | `nrfutil`、`probe-rs-tools`、`openocd`、串口工具 |
| `arm32` | ARMv7 Linux 交叉工具链、`dtc`、`ubootTools`、镜像/文件系统工具、NXP `uuu` |
| `arm64` | ARM64 Linux 交叉工具链、`dtc`、`ubootTools`、镜像/文件系统工具 |
| `allwinner` | `arm32` 基础上增加 `sunxi-tools` |
| `rockchip` | `arm64` 基础上增加 `rkdeveloptool`、`rkflashtool`、`rkbin`、`rkboot` |

Nordic shell 暂时不放 `nrf-command-line-tools`，因为它会拉 `segger-jlink` 的 Qt4 GUI 依赖，容易触发 insecure/obsolete Qt4 构建失败。要用的时候建议单独处理。

## 新增一个 MCU 厂商

比如新增 `gd`：

```text
shells/embedded/gd.nix
```

内容示例：

```nix
{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkMcuShell = import ../lib/mk-mcu-shell.nix;
in
mkMcuShell {
  inherit pkgs;
  name = "gd";
  packages = packageGroups.buildCore ++ packageGroups.debugAndFlash;
  env = {
    CHIP_VENDOR = "GigaDevice";
  };
  message = "GigaDevice MCU shell";
}
```

再在 `flake.nix` 加入口：

```nix
devShells.${system}.gd = mkDevShell ./shells/embedded/gd.nix;
```

## 新增一个 Linux SoC 平台

比如新增某个 ARMv7 平台：

```nix
{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkLinuxCrossShell = import ../lib/mk-linux-cross-shell.nix;
in
mkLinuxCrossShell {
  inherit pkgs;
  name = "my-arm-platform";
  crossPkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
  arch = "arm";
  packages = packageGroups.linuxSocCommon;
  message = "My ARM platform cross environment";
}
```

ARM64 平台通常用：

```nix
crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
arch = "arm64";
```

## 和系统包的关系

`devShells` 是项目/目标开发环境，适合临时进入：

```bash
nix develop .#allwinner
```

系统级常驻工具仍放在：

```text
modules/system/packages/development/embedded.nix
modules/system/packages/development/embedded/*.nix
```

重型 SDK 比如 ESP-IDF、Zephyr SDK、Buildroot、Yocto，建议继续做成单独 target shell。它们通常和项目版本强绑定，不适合一股脑装进全局系统包。
