# ZiYyun-NixOSConfiguration

作者：ziyun

日期：2026-07-29


## 配置概述：

- 使用 `flake.nix` 固定 NixOS、Home Manager、`nix-flatpak` 和 VS Code Server 的输入。
- 通过独立模块管理 KDE、GNOME系列软件包。
- 通过独立模块管理 硬件驱动。
- 一些嵌入式开发环境`nix-shell`。
- `embedded.nix` 集中提供 CMake、GCC、GDB、OpenOCD、串口工具等通用工具，并自动导入 Espressif、Nordic 和 STM32 模块。
- 使用 `nix-flatpak` 的 NixOS 模块声明 Flatpak 远程仓库和应用。
- 配置了南京大学 nixpkgs Git 镜像、USTC 二进制缓存和官方缓存回退地址。

## 目录结构

```text
.
├── flake.nix                         # Flake 输入和 NixOS 构建入口
├── flake.lock                        # 已锁定的输入版本和哈希
├── configuration.nix                 # 主机基础系统配置
├── hardware/
│   └── hardware-configuration.nix   # 安装时生成的硬件配置
├── modules/
│   ├── home-manager/
│   │   └── home.nix                 # ziyun 的 Home Manager 配置
│   └── nixos/
│       ├── packages/
│       │   ├── desktop/
│       │   │   ├── gnome.nix         # GNOME 相关软件
│       │   │   └── kde.nix           # KDE 相关软件
│       │   ├── development/
│       │   │   ├── general.nix       # 通用开发软件
│       │   │   ├── embedded.nix      # 嵌入式通用包和厂商模块入口
│       │   │   └── embedded/
│       │   │       ├── espressif.nix
│       │   │       ├── nordic.nix
│       │   │       └── stm.nix
│       │   └── hardware/
│       │       └── thinkpad.nix      # ThinkPad 工具
│       └── services/
│           ├── flatpak.nix           # nix-flatpak 服务配置
│           └── vscode-server.nix     # 可选的 VS Code Server 模块
└── shells/
    └── imx6ull-cross.nix             # IMX6ULL 交叉编译 shell
```

## 模块使用方法

### NixOS 主配置

`flake.nix` 的 `nixosConfigurations.nixos` 已经导入当前主机所需模块。正常情况下，在仓库根目录执行：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

只想验证配置和模块是否能求值时，可以执行：

```bash
nix flake check
```

`configuration.nix` 负责硬件配置、启动项、网络、桌面服务、用户、基础工具和系统版本等主机级设置。硬件扫描产生的文件位于 `hardware/hardware-configuration.nix`，更换机器时应重新生成或替换该文件。

### 嵌入式开发环境

只需在 NixOS 模块列表中导入：

```nix
./modules/nixos/packages/development/embedded.nix
```

该模块会自动导入：

- `espressif.nix`：`esphome`、`esptool`、`espflash`
- `nordic.nix`：nRF Command Line Tools、nRF Connect、nRF5 SDK、nRF Udev 和 `nrfutil`
- `stm.nix`：STM32CubeMX、`stm32flash` 和 `stlink`

通用工具包括 `cmake`、`gcc`、`gdb`、`gnumake`、`ninja`、`pkg-config`、`openocd`、`probe-rs-tools`、`dfu-util`、USB 工具和串口终端工具。厂商模块可以单独导入，也可以在 `embedded.nix` 中统一管理。

### Home Manager

用户配置由 `home-manager.nixosModules.home-manager` 接入，当前用户是 `ziyun`，入口文件为 `modules/home-manager/home.nix`。用户级软件放在 `home.packages`，Git 用户名和邮箱也在该文件中设置。新增只属于用户环境的软件时，应优先放在这里，而不是系统级 `environment.systemPackages`。

### Flatpak

`flake.nix` 先导入 `nix-flatpak.nixosModules.nix-flatpak`，再导入 `modules/nixos/services/flatpak.nix`。在该文件的 `services.flatpak.packages` 中填写 Flatpak 应用 ID，例如：

```nix
services.flatpak.packages = [
  "org.mozilla.firefox"
];
```

当前配置使用 SJTU 的 Flathub 镜像仓库文件，并关闭每次系统激活时的自动更新。首次安装或新增应用时，网络和 Flatpak 远程仓库可用性会影响激活时间。

### 开发 Shell

`shells/imx6ull-cross.nix` 是独立的 `mkShell` 配置，使用 `nix-shell shells/imx6ull-cross.nix` 进入 IMX6ULL 交叉编译环境。它使用 `<nixpkgs>` 通道，因此在使用前需要确保本机通道或 `NIX_PATH` 已正确设置；长期维护时可以再将它改造成 flake devShell，使其与主配置使用同一份锁定的 nixpkgs。

## 输入和源

- nixpkgs：南京大学 Git 镜像，分支为 `nixos-26.05`。
- 二进制缓存：优先使用 USTC 镜像，官方 `cache.nixos.org` 作为回退。
- Flatpak：使用 SJTU Flathub 镜像的 `flathub.flatpakrepo`。
- `nix-flatpak`、Home Manager 和 VS Code Server：通过 Flake 输入并由 `flake.lock` 锁定。

修改 Flake 输入后应同步更新并检查锁文件：

```bash
nix flake lock
nix flake check
```

## 维护建议

添加 Nix 包前，先用 `nix search nixpkgs <包名>` 或 [NixOS Packages](https://search.nixos.org/packages) 确认属性名，再运行 `nix flake check` 和 `nixos-rebuild test`。系统实际切换前建议先执行：

```bash
sudo nixos-rebuild test --flake .#nixos
```
