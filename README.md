# 🐧 ZiYyun NixOS Configuration

> **Author**: ziyun  
> **Date**: 2026-07-29  
> **Status**: Personal NixOS flake configuration 📌

---

## 📖 项目简介

这是 **ziyun** 的个人 NixOS 配置仓库，旨在将系统配置、桌面环境、开发工具链、嵌入式工具、Home Manager 用户配置以及 Flatpak 应用管理拆分为**清晰、可复用**的 Nix 模块，让日常维护变得集中、可控且易于审查。  

✨ **核心特点**：

- 基于 **Flake** 锁定 `nixpkgs`、Home Manager、`nix-flatpak` 和 VS Code Server 的版本。
- **系统级**与**用户级**配置分离：NixOS 模块管理系统能力，Home Manager 模块管理用户环境。
- 桌面、硬件、通用开发、嵌入式开发和服务按主题模块化。
- 嵌入式开发通过统一入口 `embedded.nix` 导入 Espressif、Nordic、STM32 等原子模块。
- Flatpak 采用 `nix-flatpak.nixosModules.nix-flatpak` 声明式管理远程仓库和应用。
- 预配置国内镜像加速：NJU nixpkgs Git 镜像、USTC Nix 二进制缓存、SJTU Flathub 镜像。

---

## 📁 仓库结构

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
│   └── system/                       # 系统级 NixOS 模块集合
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
├── shells/
│   └── imx6ull-cross.nix             # IMX6ULL 交叉编译 shell
└── scripts/
    ├── bootstrap.sh                  # Live ISO 一键拉取仓库入口
    └── install.sh                    # NixOS 安装脚本
```

> ℹ️ `modules/system` 只表示“系统级 NixOS 模块集合”，非真实系统目录 `/etc/nixos`。

---

### Install From Live ISO

进入 NixOS 启动盘后，先确认网络可用，再执行：

```bash
curl -L https://raw.githubusercontent.com/0zhangchibang0/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash
```

默认模式要求你已经手动分区、格式化并把目标根分区挂载到 `/mnt`。脚本会 clone 仓库、复制配置到 `/mnt/etc/nixos`、生成硬件配置、执行 `nix flake check`，最后运行：

```bash
nixos-install --flake .#nixos
```

如果你手动挂载，但启动盘不是配置里默认的 `/dev/sda`，可以只传 `--disk` 生成安装机对应的 bootloader 覆盖，不会格式化磁盘：

```bash
curl -L https://raw.githubusercontent.com/0zhangchibang0/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash -s -- -- --disk /dev/nvme0n1
```

如果要让脚本自动清空整块磁盘、分区、格式化并挂载，必须显式传入目标磁盘和 `--erase`：

```bash
curl -L https://raw.githubusercontent.com/0zhangchibang0/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash -s -- -- --disk /dev/sda --erase
```

脚本会显示目标磁盘信息，并要求输入 `ERASE /dev/sda` 才会继续。NVMe 设备示例：

```bash
curl -L https://raw.githubusercontent.com/0zhangchibang0/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash -s -- -- --disk /dev/nvme0n1 --erase
```

只想准备文件但暂不安装时：

```bash
sudo bash scripts/install.sh --mountpoint /mnt --skip-install
```

### Rebuild System

在仓库根目录执行：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

若仅验证配置能否求值和构建，建议先使用：

```bash
nix flake check
sudo nixos-rebuild test --flake .#nixos
```

---

### ➕ 添加系统模块

系统级模块放在 `modules/system/` 下，然后在 `flake.nix` 的 `nixosConfigurations.nixos.modules` 列表中引用即可。例如新增一个服务模块：

```nix
./modules/system/services/example.nix
```

**适合放在系统模块中的内容**包括：系统服务、驱动、桌面环境、系统级开发工具、udev 规则、Flatpak 远程、需要 root 权限的功能等。

---

### 🧑‍💻 添加 Home Manager 软件包

用户级配置入口是 `modules/home-manager/home.nix`。  
仅服务于 `ziyun` 用户会话的软件、Git 用户信息、Shell 配置、编辑器用户偏好等，**优先放在这里**，而不是 `environment.systemPackages`。

---

### 🔧 嵌入式开发

嵌入式总入口为：

```nix
./modules/system/packages/development/embedded.nix
```

该模块提供通用嵌入式工具：`cmake`、`gcc`、`gdb`、`gnumake`、`ninja`、`pkg-config`、`openocd`、`probe-rs-tools`、`dfu-util`、`libusb1`、`minicom`、`picocom`、`screen`、`usbutils` 等。

**厂商专用模块**（原子化）：

- `embedded/espressif.nix`：`esphome`、`esptool`、`espflash`
- `embedded/nordic.nix`：`nrf-command-line-tools`、`nrfconnect`、`nrf5-sdk`、`nrf-udev`、`nrfutil`
- `embedded/stm.nix`：`stm32cubemx`、`stm32flash`、`stlink`

默认只需在 `flake.nix` 导入 `embedded.nix`，无需单独导入厂商模块。

---

### 📦 Flatpak 声明式管理

Flatpak 通过 `nix-flatpak.nixosModules.nix-flatpak` 提供的 NixOS 模块实现，配置文件为：

```nix
./modules/system/services/flatpak.nix
```

在 `services.flatpak.packages` 中添加应用 ID，例如：

```nix
services.flatpak.packages = [
  "org.mozilla.firefox"
];
```

当前远程仓库使用 **SJTU Flathub 镜像**：

```text
https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
```

---

### 🐚 开发 Shell 环境

`shells/imx6ull-cross.nix` 是一个独立的 `mkShell`，可通过以下方式进入：

```bash
nix-shell shells/imx6ull-cross.nix
```

目前它使用 `<nixpkgs>` 通道。长期维护时建议迁移到 flake 的 `devShells`，使交叉编译环境与系统配置共享锁定版本的 nixpkgs。

---

## 🌐 镜像源配置

| 组件         | 镜像地址                                                                 |
|--------------|--------------------------------------------------------------------------|
| nixpkgs      | NJU Git 镜像，分支 `nixos-26.05`                                        |
| Nix 二进制缓存 | USTC 镜像，`cache.nixos.org` 作为回退                                  |
| Flatpak      | SJTU Flathub 镜像                                                       |

更新 flake 输入后建议执行：

```bash
nix flake lock
nix flake check
```

---

## 🗺️ 开发路线图

- [ ] **阶段一**：稳定当前模块结构，确保 `nix flake check` 和 `nixos-rebuild test` 通过。
- [ ] **阶段二**：继续原子化桌面模块，将 KDE、GNOME 和公共桌面工具拆分得更清晰。
- [ ] **阶段三**：补全 ThinkPad 硬件模块，覆盖 T480、X230i、P14s 的常用驱动和电源管理。
- [ ] **阶段四**：原子化语言开发环境（Python、Rust、Node.js、Java、.NET 等）。
- [ ] **阶段五**：细分 IDE 和编辑器模块（VS Code、JetBrains、Neovim）。
- [ ] **阶段六**：评估 Noctalia 的上游地址与模块接入方式，纳入 flake 输入。
- [ ] **阶段七**：将 `shells/imx6ull-cross.nix` 迁移为 flake 的 `devShell`。

---

## 📝 维护注意事项

添加 Nix 包前，请先确认包名：

```bash
nix search nixpkgs <package-name>
```

或访问 [NixOS Packages](https://search.nixos.org/packages)。

新增或移动模块后，**务必**执行：

```bash
nix flake check
sudo nixos-rebuild test --flake .#nixos
```

确认无误后再执行 `switch`。

---

*Happy NixOS hacking!* 🎉
