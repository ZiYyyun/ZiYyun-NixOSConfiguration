# ZiYyun NixOS Configuration

> Author: ziyun
>
> Date: 2026-07-29
>
> Status: personal NixOS flake configuration

这是 ziyun 的个人 NixOS 配置仓库。项目目标是把系统配置、桌面环境、开发工具、嵌入式工具链、Home Manager 用户配置和 Flatpak 应用管理拆成清晰的 Nix 模块，让日常维护尽量集中、可复用、可审查。

## Features

- 基于 Flake 固定 `nixpkgs`、Home Manager、`nix-flatpak` 和 VS Code Server 输入。
- 系统级配置和用户级配置分离：NixOS 模块负责系统能力，Home Manager 模块负责用户环境。
- 桌面、硬件、通用开发、嵌入式开发和服务配置按主题拆分。
- 嵌入式开发环境使用统一入口 `embedded.nix`，再导入 Espressif、Nordic、STM32 原子模块。
- Flatpak 使用 `nix-flatpak.nixosModules.nix-flatpak` 声明式管理远程仓库和应用。
- 已配置国内镜像：NJU nixpkgs Git 镜像、USTC Nix 二进制缓存、SJTU Flathub 镜像。

## Repository Layout

```text
.
├── flake.nix                         # Flake 输入和 NixOS 构建入口
├── flake.lock                        # 锁定的输入版本和哈希
├── configuration.nix                 # 当前主机的基础系统配置
├── configuration.nix.d               # 旧配置备份/迁移参考
├── hardware/
│   └── hardware-configuration.nix    # 安装时生成的硬件配置
├── modules/
│   ├── home-manager/
│   │   └── home.nix                  # ziyun 的 Home Manager 用户配置
│   └── system/
│       ├── packages/
│       │   ├── desktop/
│       │   │   ├── gnome.nix         # GNOME 相关包
│       │   │   └── kde.nix           # KDE 相关包
│       │   ├── development/
│       │   │   ├── general.nix       # 通用开发工具和 IDE
│       │   │   ├── embedded.nix      # 嵌入式通用包和厂商模块入口
│       │   │   └── embedded/
│       │   │       ├── espressif.nix # Espressif ESP 工具
│       │   │       ├── nordic.nix    # Nordic nRF 工具
│       │   │       └── stm.nix       # STM32 工具
│       │   └── hardware/
│       │       └── thinkpad.nix      # ThinkPad 相关工具
│       └── services/
│           ├── flatpak.nix           # nix-flatpak 服务配置
│           └── vscode-server.nix     # VS Code Server 模块配置
└── shells/
    └── imx6ull-cross.nix             # IMX6ULL 交叉编译 shell
```

`modules/system` 只表示“系统级 NixOS 模块集合”，故意不命名为 `modules/nixos`，避免和真实系统目录 `/etc/nixos` 混淆。

## Usage

### Rebuild System

在仓库根目录执行：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

只验证配置能否求值和构建时，建议先使用：

```bash
nix flake check
sudo nixos-rebuild test --flake .#nixos
```

### Add A System Module

系统级模块放在 `modules/system/` 下，再加入 `flake.nix` 的 `nixosConfigurations.nixos.modules` 列表。例如新增一个服务模块：

```nix
./modules/system/services/example.nix
```

适合放在系统模块里的内容包括系统服务、驱动、桌面环境、系统级开发工具、udev 规则、Flatpak 远程和需要 root 激活的能力。

### Add Home Manager Packages

用户级配置入口是 `modules/home-manager/home.nix`。只服务于 `ziyun` 用户会话的软件、Git 用户信息、Shell 配置、编辑器用户配置等，优先放在这里，而不是 `environment.systemPackages`。

### Embedded Development

嵌入式开发总入口是：

```nix
./modules/system/packages/development/embedded.nix
```

这个模块提供通用嵌入式工具，例如 `cmake`、`gcc`、`gdb`、`gnumake`、`ninja`、`pkg-config`、`openocd`、`probe-rs-tools`、`dfu-util`、`libusb1`、`minicom`、`picocom`、`screen` 和 `usbutils`。

厂商相关工具拆在独立原子模块中：

- `embedded/espressif.nix`: `esphome`、`esptool`、`espflash`
- `embedded/nordic.nix`: `nrf-command-line-tools`、`nrfconnect`、`nrf5-sdk`、`nrf-udev`、`nrfutil`
- `embedded/stm.nix`: `stm32cubemx`、`stm32flash`、`stlink`

默认情况下只需要在 `flake.nix` 导入 `embedded.nix`，不需要单独导入厂商模块。

### Flatpak

Flatpak 通过 `nix-flatpak.nixosModules.nix-flatpak` 提供的 NixOS module 实现，仓库内配置文件是：

```nix
./modules/system/services/flatpak.nix
```

在 `services.flatpak.packages` 中添加应用 ID：

```nix
services.flatpak.packages = [
  "org.mozilla.firefox"
];
```

当前远程仓库使用 SJTU Flathub 镜像：

```text
https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
```

### Development Shells

`shells/imx6ull-cross.nix` 是独立的 `mkShell`：

```bash
nix-shell shells/imx6ull-cross.nix
```

它目前使用 `<nixpkgs>` 通道。长期维护时可以迁移到 flake `devShells`，这样交叉编译环境会和系统配置共享同一份锁定的 nixpkgs。

## Mirrors

- nixpkgs: NJU Git 镜像，分支 `nixos-26.05`
- Nix substituter: USTC 二进制缓存，官方 `cache.nixos.org` 作为回退
- Flatpak: SJTU Flathub 镜像

更新 flake 输入后建议执行：

```bash
nix flake lock
nix flake check
```

## Roadmap

- [ ] 阶段一：稳定当前模块结构，确保 `nix flake check` 和 `nixos-rebuild test` 通过。
- [ ] 阶段二：继续原子化桌面模块，把 KDE、GNOME 和公共桌面工具拆分得更清楚。
- [ ] 阶段三：补全 ThinkPad 硬件模块，覆盖 T480、X230i、P14s 的常用驱动和电源管理。
- [ ] 阶段四：原子化语言开发环境，例如 Python、Rust、Node.js、Java、.NET。
- [ ] 阶段五：细分 IDE 和编辑器模块，例如 VS Code、JetBrains、Neovim。
- [ ] 阶段六：评估 Noctalia 的上游地址和模块接入方式，再加入 flake 输入。
- [ ] 阶段七：把 `shells/imx6ull-cross.nix` 迁移为 flake devShell。

## Maintenance Notes

添加 Nix 包前，先用下面任一方式确认包名：

```bash
nix search nixpkgs <package-name>
```

或访问 [NixOS Packages](https://search.nixos.org/packages)。新增或移动模块后，至少执行：

```bash
nix flake check
sudo nixos-rebuild test --flake .#nixos
```

确认无误后再执行 `switch`。
