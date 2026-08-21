# ZiYyun NixOS Configuration

This repository is ziyun's personal NixOS flake. It keeps host profiles, desktop environments, hardware quirks, Home Manager user configuration, KDE/Niri dotfiles, Flatpak apps, development tools, and embedded dev shells in one reproducible place.

Current target release: **NixOS 26.05**.

## What Is Managed

| Area | Current State |
| --- | --- |
| Nix | Flakes enabled, `nix-command` enabled, Lix enabled from nixpkgs, `nixpkgs` pinned to the `nixos-26.05` Git branch |
| Binary cache | Official `cache.nixos.org` first, domestic university mirrors as fallback |
| User | Normal user `ziyun`, wheel/networkmanager groups, Home Manager enabled |
| Locale | `zh_CN.UTF-8`, timezone `Asia/Shanghai`, XKB layout `cn` |
| Network | NetworkManager, OpenSSH |
| Audio | PipeWire with ALSA, 32-bit ALSA, PulseAudio compatibility, RTKit |
| Printing | CUPS |
| Browser | Firefox through `programs.firefox.enable`; Microsoft Edge in Home Manager packages |
| Input method | Fcitx5 + Rime + Chinese addons, with GTK/Qt/X11 session variables |
| D-Bus | Reference `dbus-daemon` implementation, chosen because `dbus-broker` was unreliable during live rebuilds |
| Flatpak | `nix-flatpak`, Flathub via SJTU mirror, Tor Browser launcher installed |
| WinBoat/Windows VM | ThinkPad-P14s enables Docker, KVM/libvirt, and WinBoat prerequisites; the WinBoat GUI owns the Windows container |
| Home Manager | Git identity, user apps, VS Code Server, Ghostty config, KDE dotfiles, Niri config, nixvim |
| Editors | Nixvim/Neovim, VS Code, CLion, Eclipse Embedded CDT, Code::Blocks |
| Embedded IDEs | STM32CubeMX is kept out of the global system closure because it is a large vendor download that can fail during rebuild; install it only when needed |
| Terminal | Ghostty installed and configured; VM may need software GL, real machines are the priority |
| Package GUIs | KDE Discover, GNOME Software, Warehouse, KDE Flatpak KCM, `nix-search-tv` |
| Desktop shells | KDE Plasma 6, GNOME, Niri, Noctalia |
| Theme resources | SDDM Astronaut, Fluent purple icons, Breeze/hicolor icon fallback, Oreo purple cursor |
| Embedded | MCU/vendor/SoC toolchain definitions live in Flake devShells, not in the global system profile |

## Flake Inputs

| Input | Purpose |
| --- | --- |
| `nixpkgs` | Main package set, pinned to the `nixos-26.05` Git branch |
| `flake-parts` | Shared transitive input for nixvim and VS Code Server |
| `nixpkgs-lib` | Shared flake-parts library input |
| `systems` | Shared systems list for nixvim |
| `home-manager` | Home Manager release `26.05` |
| `nix-flatpak` | Declarative Flatpak remote and package management |
| `nixos-hardware` | Official hardware profiles for ThinkPads and desktop PC defaults |
| `nixos-vscode-server` | VS Code Remote server support through Home Manager |
| `noctalia` | Noctalia shell NixOS module |
| `nixvim` | Flake-based Neovim configuration |

GitHub-backed inputs use the official `github:owner/repository` flake
references. No third-party GitHub proxy is configured by this repository.

Lix is enabled with `nix.package = pkgs.lix`, so it is fetched from nixpkgs and
does not need a separate `git.lix.systems` flake input.

## Host Outputs

| Flake output | Desktop/session | Hardware profile | Storage notes |
| --- | --- | --- | --- |
| `kde-default` | KDE Plasma 6 + SDDM, also includes Niri + Noctalia | none | default KDE layout, root `/dev/sda1` |
| `niri-default` | Niri + Noctalia, SDDM default session set to Niri | none | default Niri layout, root `/dev/sda1` |
| `gnome-default` | GNOME + GDM, also includes Niri + Noctalia | none | default GNOME layout, root `/dev/sda1` |
| `desktop-default` | KDE Plasma 6 + SDDM, also includes Niri + Noctalia | `common-pc`, `common-pc-ssd` | Desktop PC layout, root `/dev/nvme0n1p2` |
| `ThinkPad-x270` | GNOME main desktop + SDDM session picker, also includes Niri + Noctalia | `lenovo-thinkpad-x270` | root `/dev/sda2` |
| `ThinkPad-x230i` | GNOME main desktop + SDDM session picker, also includes Niri + Noctalia | `lenovo-thinkpad-x230` | legacy GRUB on `/dev/sdb`; root and swap mounted by UUID so the NTFS disk labeled `系统` is not touched |
| `ThinkPad-P14s` | KDE Plasma 6 + SDDM | `lenovo-thinkpad-p14s-intel-gen5` | UEFI layout: ESP `/dev/sda1` mounted at `/boot`, root `/dev/sda2`, swap `/dev/sda3`; WinBoat state is managed by the WinBoat app; fingerprint reader enabled via `fprintd`; WayDroid runtime enabled |
| `docker-test` | no desktop | none | test-only fake root, no bootloader |

Hardware-specific disk choices stay inside each host directory. Bootloader selection is explicit: import `hosts/common/boot/legacy.nix` for BIOS/MBR machines, or `hosts/common/boot/uefi.nix` for UEFI machines.

## Directory Map

```text
.
|-- flake.nix
|-- flake.lock
|-- configuration.nix
|-- hosts/
|   |-- common/
|   |   |-- boot/
|   |   |   |-- legacy.nix
|   |   |   `-- uefi.nix
|   |   |-- hardware-configuration.nix
|   |   `-- installation-boot.nix
|   |-- kde-default/
|   |-- niri-default/
|   |-- gnome-default/
|   |-- desktop-default/
|   |-- docker-test/
|   |-- ThinkPad-x270/
|   |-- ThinkPad-x230i/
|   `-- ThinkPad-P14s/
|-- modules/
|   |-- system/
|   |   |-- desktop/
|   |   |   |-- kde.nix
|   |   |   |-- gnome.nix
|   |   |   |-- niri.nix
|   |   |   `-- noctalia.nix
|   |   |-- profiles/
|   |   |   |-- kde.nix
|   |   |   |-- gnome.nix
|   |   |   |-- niri.nix
|   |   |   `-- noctalia.nix
|   |   `-- services/
|   |       |-- dbus.nix
|   |       |-- input-method.nix
|   |       |-- sddm.nix
|   |       |-- flatpak.nix
|   |       |-- winboat.nix
|   |       |-- fprintd.nix
|   |       `-- waydroid.nix
|   `-- home/
|       |-- accounts/
|       |-- config-files/
|       `-- programs/
|-- packages/
|   |-- system/
|   |   |-- apps.nix
|   |   |-- base.nix
|   |   |-- development.nix
|   |   `-- hardware/
|   |-- home/
|   `-- custom/
|-- dotfiles/
|   |-- ghostty/
|   |-- kde/
|   `-- niri/
|-- dev_toolchains/
|   |-- libs/
|   |-- compilers/
|   `-- embedded/
|-- shells/
|   |-- bootstrap.sh
|   |-- install.sh
|   `-- export-dotfiles.sh
|-- wiki/
|   |-- Dev-Embedded-Toolchains.md
|   |-- Dev-Programming-Toolchains.md
|   `-- Host-Switching.md
`-- TODO.md
```

## Structure Rules

The repo is split by the work you usually do:

- Install or remove global system packages: edit `packages/system/*.nix`.
- Install or remove user apps: edit `packages/home/apps.nix`.
- Change system services, desktop enablement, input method, Flatpak, or SDDM: edit `modules/system/`.
- Change Home Manager config, editor config, VS Code Server, or dotfile links: edit `modules/home/`.
- Change real dotfile payloads: edit `dotfiles/`.
- Add tools or libraries to a programming development environment: edit `dev_toolchains/libs/compiler-packages.nix`.
- Add tools to an embedded MCU/SoC environment: edit `dev_toolchains/libs/embedded-packages.nix`.
- Change a host machine's disks, boot mode, or hardware profile: edit `hosts/<host>/default.nix` and `hosts/<host>/hardware-configuration.nix`.

The important rule is: root-level folders are real daily entrypoints. There is no root-level `profiles/`, and desktop-specific packages are kept with the matching desktop module in `modules/system/desktop/`.

## System Layers

### Base System

`configuration.nix` contains the shared base system:

- Nix flakes and substituters
- hostname `nixos`
- NetworkManager
- Chinese locale and Shanghai timezone
- CUPS
- PipeWire
- user `ziyun`
- Firefox
- unfree packages
- OpenSSH
- `system.stateVersion = "26.05"`

System packages now live in `packages/system/base.nix`, `packages/system/apps.nix`, and `packages/system/development.nix`.

### Services

`modules/system/services/default.nix` imports:

- `dbus.nix`: sets `services.dbus.implementation = "dbus"`
- `input-method.nix`: Fcitx5, Rime, Chinese addons, config tool, input method environment variables
- `sddm.nix`: SDDM Astronaut theme

`flatpak.nix` is imported only by host profiles that enable `nix-flatpak`.

`winboat.nix` is imported by `ThinkPad-P14s` only. It enables Docker,
KVM/libvirt, the `docker`/`kvm`/`libvirtd` user groups, and supporting CLI
tools. It does not start a separate `dockurr/windows` container; the WinBoat GUI
manages its own container and state.

`fprintd.nix` is imported by `ThinkPad-P14s` only. It enables `fprintd` for
the Synaptics `06cb:00f9` fingerprint reader (supported by libfprint 1.94.10).
PAM login integration is automatic (`fprintAuth` defaults to
`services.fprintd.enable`): login/SDDM, KDE lock screen (`kde-fingerprint`
service), swaylock, and sudo all accept a fingerprint, falling back to
password. Enroll with `fprintd-enroll` and check with `fprintd-list`.

`waydroid.nix` is imported by `ThinkPad-P14s` only. It enables the WayDroid
runtime (`virtualisation.waydroid.enable`). The Android system image is not
part of the Nix closure; download and initialize it with
`shells/waydroid-init.sh` (supports `--proxy` and `--mirror` for faster
downloads). See the "WayDroid" section below.

### Desktop Profiles

Desktop profiles live in `modules/system/profiles/` and compose one or more desktop modules:

- `kde.nix`
- `gnome.nix`
- `niri.nix`
- `noctalia.nix`

Hosts import one of these profiles and keep their own hardware layout locally.
The KDE and GNOME profiles also include Niri + Noctalia as alternate sessions.

### Desktop Modules

Desktop modules live in `modules/system/desktop/*.nix`. Each file keeps desktop enablement and that desktop's specific packages together:

- KDE: X server, SDDM, Plasma 6, KDE apps, icon/cursor/theme resources
- GNOME: X server, GDM, GNOME, GNOME-specific apps
- Niri: Wayland compositor, portals, graphics support, Niri helper tools
- Noctalia: Noctalia module settings

There is intentionally no second desktop package layer now. If a package only makes sense for KDE, edit `modules/system/desktop/kde.nix`; if it should be installed everywhere, edit `packages/system/apps.nix` or `packages/system/development.nix`.

### ThinkPad Tools

`packages/system/hardware/thinkpad.nix` only keeps ThinkPad-specific system packages:

- `tpacpi-bat`
- `hdapsd`

## Home Manager

Home Manager is wired in `flake.nix` and imports `modules/home/default.nix`, `packages/home`, nixvim's Home Manager module, and VS Code Server.

`modules/home` keeps configuration only:

- Git username/email
- nixvim
- VS Code Server
- config file links for repository-managed dotfiles

`packages/home/default.nix` keeps the user package list:

- `honeyfetch`
- `spotify`
- `winboat`
- `clash-verge-rev`
- `obsidian`
- `koodo-reader`
- `qq`
- `microsoft-edge`
- `eudic`
- `libreoffice`
- `wine`

## Dotfiles

Real dotfiles live in `dotfiles/`:

```text
dotfiles/
|-- ghostty/
|-- kde/
|   `-- config/
|-- noctalia/
`-- niri/
```

`modules/home/config-files/*.nix` hot-links those files into their XDG
paths using Home Manager's `config.lib.file.mkOutOfStoreSymlink`: the
managed files are symlinked **directly to this repository** (not copied
into the Nix store), so editing `dotfiles/...` takes effect immediately —
no rebuild needed. The repo is the single source of truth.

Caveats:

- KDE apps save config atomically (temp file + rename), which replaces the
  symlink with a regular file. After changing a setting inside a KDE app,
  the link is broken; restore it with `home-manager switch` (your manual
  changes are kept as `*.hm-backup`), or copy the file back into the repo
  first if you want to keep the new values.
- Text editors that write in place (VS Code, vim, nano) keep the symlink
  intact.
- `shells/export-dotfiles.sh` is kept as a one-shot export for one-time
  migrations (e.g. first import of a running session's config).

## Nixvim

`modules/home/programs/nixvim.nix` enables flake-based nixvim.

Current behavior:

- `nvim` is the default editor
- `vi` and `vim` aliases are enabled
- Catppuccin Mocha colorscheme
- line numbers and relative numbers
- 2-space indentation
- true color
- sign column always visible
- leader key is Space
- wl-copy clipboard provider

Plugins:

- Treesitter
- Telescope
- Lualine
- Which-key
- Web devicons
- Yazi

Keymaps:

| Key | Action |
| --- | --- |
| `<leader>ff` | Telescope find files |
| `<leader>fg` | Telescope live grep |
| `<leader>e` | Open Yazi |

## Package Layers

Global system packages:

- `packages/system/base.nix`
- `packages/system/apps.nix`
- `packages/system/development.nix`

User packages:

- `packages/home/apps.nix`

Local derivations:

- `packages/custom/trae-code/default.nix`

## Embedded Development

Embedded packages are not installed globally. Use devShells for vendor SDKs, flashing tools, serial tools, and cross toolchains:

- STM: `nix develop .#stm`
- Espressif: `nix develop .#esp`
- Nordic: `nix develop .#nordic`
- SEGGER: `nix develop .#segger`
- LuatOS (合宙): `nix develop .#luatos`
- ARM32 Linux SoC/i.MX6ULL: `nix develop .#arm32`
- ARM64 Linux SoC: `nix develop .#arm64`
- Allwinner: `nix develop .#allwinner`
- Rockchip: `nix develop .#rockchip`

This keeps `nixos-rebuild` small and avoids one vendor package, such as an old Nordic/J-Link Qt4 dependency path, from breaking the whole system build.

## Dev Toolchains

Flake dev shells are split by purpose:

- `dev_toolchains/compilers/`: common programming environments for project work.
- `dev_toolchains/embedded/`: MCU/vendor/SoC environments for flashing, debugging, SDK tools, and cross compilation.
- `dev_toolchains/libs/`: shared helpers and reusable package groups.

Common programming shells:

```bash
nix develop
nix develop .#c
nix develop .#cpp
nix develop .#c-cpp
nix develop .#rust
nix develop .#python
nix develop .#node
nix develop .#go
nix develop .#java
nix develop .#dotnet
```

Embedded shells:

```bash
nix develop .#stm
nix develop .#esp
nix develop .#nordic
nix develop .#segger
nix develop .#arm32
nix develop .#arm64
nix develop .#allwinner
nix develop .#rockchip
```

`nix develop .#esp` and `nix develop .#esp-idf` enter the same unified ESP32
shell (see below).

`devShells.default`, `.#c`, `.#cpp`, and `.#c-cpp` point to the same C/C++ shell, so plain `nix develop` is useful for clangd/pthread/libmodbus/Paho MQTT C/CMake projects.

### ESP-IDF (VSCode + idf.py)

The Espressif VSCode extension is only officially supported on Debian/Ubuntu
(it downloads its own Python env and toolchain into `~/.espressif`). On NixOS,
the unified `esp` shell provides the complete ESP-IDF framework plus toolchains
for all ESP32 targets (from
[mirrexagon/nixpkgs-esp-dev](https://github.com/mirrexagon/nixpkgs-esp-dev)),
merged with the flashing/serial tools (`esptool`, `espflash`, `platformio`,
`openocd`, serial tools). `esp` and `esp-idf` are the same shell.

```bash
nix develop .#esp        # == nix develop .#esp-idf
```

Inside the shell, `idf.py` is ready:

```bash
idf.py set-target esp32s3
idf.py build
idf.py -p /dev/ttyACM0 flash monitor
```

For VSCode: put `use flake <path-to-this-repo>#esp` in the project's
`.envrc` (direnv is already enabled), open the project in Code, and run
`idf.py` from the integrated terminal. `idf.py` generates
`compile_commands.json`, so clangd works too. Do not use the Espressif
extension's setup wizard on NixOS.

Note: esp-dev is built against nixpkgs 25.11 (it needs `python310`, which
26.05 dropped), so the shell uses a separate `nixpkgs-esp` input.

Home Manager enables `direnv` with `nix-direnv`, so VS Code can load a project's `.envrc` and expose the devShell environment to clangd.

For one-off VS Code sessions, start Code inside the shell instead of after it exits:

```bash
nix develop .#c --command code .
```

Details are in [wiki/Dev-Programming-Toolchains.md](wiki/Dev-Programming-Toolchains.md) and [wiki/Dev-Embedded-Toolchains.md](wiki/Dev-Embedded-Toolchains.md).

## Flatpak

Flatpak is configured in:

```text
modules/system/services/flatpak.nix
```

Current remote:

```text
https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
```

Current packages:

- `org.torproject.torbrowser-launcher`

Flatpak updates are not run automatically during every system activation:

```nix
services.flatpak.update.onActivation = false;
```

GUI helpers installed by the system:

- Warehouse
- GNOME Software
- KDE Discover
- KDE Flatpak KCM

## WinBoat Windows VM

`ThinkPad-P14s` imports:

```text
modules/system/services/winboat.nix
```

During rebuild, Nix enables Docker and KVM/libvirt and installs the CLI tools
WinBoat needs. It intentionally does not install `/etc/winboat/compose.yml` or
start a separate WinBoat backend service, because the WinBoat GUI creates and manages
its own Docker container.

If an older revision of this repository already started the removed backend,
clean it once after switching to the new configuration:

```bash
sudo systemctl stop winboat-windows.service 2>/dev/null || true
sudo systemctl disable winboat-windows.service 2>/dev/null || true
sudo docker rm -f winboat-windows 2>/dev/null || true
sudo rm -f /etc/winboat/compose.yml
sudo rmdir /etc/winboat 2>/dev/null || true
```

Do not remove `/var/lib/winboat` unless you have separately backed up the
Windows disk and explicitly intend to delete it.

Then restart WinBoat from the desktop launcher and inspect the app-managed
container if it still fails:

```bash
docker logs WinBoat
ls -la ~/.winboat
```

Backup these paths:

- this git repository, especially `flake.lock`
- `~/.winboat`
- Docker volumes/containers created by WinBoat
- important data inside Windows itself

The Docker image can be pulled again. The installed Windows disk, UEFI/NVRAM
state, and installation progress are app-managed state, so do not rely on
`docker save` alone as a Windows backup.

## WayDroid

`ThinkPad-P14s` enables the WayDroid runtime (`virtualisation.waydroid.enable`).
The default nixpkgs kernel already ships the required `ANDROID_BINDER_IPC`,
`ANDROID_BINDERFS`, `MEMFD_CREATE`, and PSI support, so no custom kernel is
needed.

The Android image is a ~1.4 GB download that does not belong in the Nix store.
Fetch and initialize it with:

```bash
# direct sourceforge (slow), or use your clash proxy (fast):
sudo bash shells/waydroid-init.sh --proxy http://127.0.0.1:7897

# or a custom mirror prefix (needs vendor/ and system/lineage/ layout):
sudo bash shells/waydroid-init.sh --mirror https://your-mirror.example/waydroid
```

The script downloads the GApps variant of LineageOS 20.0 (Android 13) by
default, extracts `system.img`/`vendor.img` into `/var/lib/waydroid/images/`,
and runs `waydroid init -f -s GAPPS`.

After init, run inside a Wayland session (KDE Plasma 6 or Niri):

```bash
sudo waydroid container start
waydroid show-full-ui
waydroid app list
```

GApps note: logging into Google requires device certification first, otherwise
the Play Store reports an uncertified device. See the [WayDroid Google Play
certification FAQ](https://docs.waydro.id/faq/google-play-certification).

## Windows Apps via Wine (WinApps)

For Windows-only LAN software (飞秋 FeiQ, 红蜘蛛 Red Spider) that cannot use
the WinBoat container network, `packages/custom/winapps/` packages them with
Wine, Nix-reproducibly:

```bash
nix run .#feiq                 # 飞秋 LAN messenger (official green exe, pinned hash)
nix run .#redspider-student    # 红蜘蛛学生端 (official InstallShield zip, silent install)
```

Both apps get KDE menu entries, use per-app Wine prefixes under
`~/.local/share/winapps/`, and run directly on the host network (LAN UDP
broadcast works — no container isolation). CJK fonts (`wqy-zenhei`,
`noto-fonts-cjk-sans`) are enabled system-wide in `configuration.nix`.
Details: `packages/custom/winapps/README.md`.

## Embedded Toolchains (No Keil)

Keil (MDK/C51) was evaluated under Wine but its InstallShield installer
reliably reports "installation is occupied" inside Wine (a stub-level
incompatibility), so Keil is intentionally **not** packaged. Use the dev
shells instead:

- **8051**: `sdcc` compiler + `stcflash` flashing (add to a devShell as needed)
- **STM32**: `gcc-arm-none-eabi` cross toolchain via `nix develop .#arm32`,
  CMake/Makefile projects (STM32CubeMX can export Makefiles), flashing with
  `stm32flash` / `openocd`
- ESP32: `nix develop .#esp` (ESP-IDF + esptool/espflash/platformio)

## Install From Live ISO

Boot into a NixOS live ISO, connect to the network, then run:

```bash
curl -L https://raw.githubusercontent.com/ZiYyyun/ZiYyun-NixOSConfiguration/main/shells/bootstrap.sh | sudo bash
```

The default path assumes you already partitioned, formatted, and mounted the target system at `/mnt`. The installer prepares the repo under `/mnt/etc/nixos` and installs the default flake output.

To specify a disk without erasing it:

```bash
curl -L https://raw.githubusercontent.com/ZiYyyun/ZiYyun-NixOSConfiguration/main/shells/bootstrap.sh | sudo bash -s -- -- --disk /dev/nvme0n1
```

To erase, partition, format, and mount a disk, pass `--erase` explicitly:

```bash
curl -L https://raw.githubusercontent.com/ZiYyyun/ZiYyun-NixOSConfiguration/main/shells/bootstrap.sh | sudo bash -s -- -- --disk /dev/sda --erase
```

The script asks for an explicit confirmation such as:

```text
ERASE /dev/sda
```

To prepare files but skip installation:

```bash
sudo bash shells/install.sh --mountpoint /mnt --skip-install
```

## Rebuild

From the repository root:

```bash
sudo nixos-rebuild switch --flake .#ThinkPad-P14s
```

Safer test command:

```bash
sudo nixos-rebuild test --flake .#ThinkPad-P14s
```

Build without switching:

```bash
nix build .#nixosConfigurations.ThinkPad-P14s.config.system.build.toplevel
```

Useful host commands:

```bash
sudo nixos-rebuild switch --flake .#kde-default
sudo nixos-rebuild switch --flake .#niri-default
sudo nixos-rebuild switch --flake .#gnome-default
sudo nixos-rebuild switch --flake .#desktop-default
sudo nixos-rebuild switch --flake .#ThinkPad-x270
sudo nixos-rebuild switch --flake .#ThinkPad-x230i
sudo nixos-rebuild switch --flake .#ThinkPad-P14s
```

If you only want a lightweight evaluation target:

```bash
nix build .#nixosConfigurations.docker-test.config.system.build.toplevel
```

## Lix

Lix is enabled directly from nixpkgs:

```nix
nix.package = pkgs.lix;
```

This avoids an extra `git.lix.systems` input. Updating Lix now follows the
normal nixpkgs update path.

## Mirrors

| Component | Mirror |
| --- | --- |
| nixpkgs input | Git-pinned `github:NixOS/nixpkgs/nixos-26.05` |
| GitHub flake inputs | Official `github:owner/repository` references |
| Lix | from nixpkgs |
| Nix binary cache | official `https://cache.nixos.org/` first |
| Domestic cache fallback | SJTU, TUNA, USTC Nix channel stores |
| Flatpak | SJTU Flathub mirror |

Do not pin `nixpkgs` to a channel tarball mirror. Mirrors may repack tarballs,
which changes the `narHash` and breaks fresh installations.

Temporary rebuild with explicit substituters:

```bash
sudo nixos-rebuild switch --flake .#ThinkPad-P14s --option substituters "https://cache.nixos.org/ https://mirror.sjtu.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store"
```

## Updating Packages And Modules

All system packages, Home Manager modules, nixos-hardware profiles, nixvim,
nix-flatpak, Noctalia, VS Code Server support, and Lix are pinned by
`flake.lock`. Updating the lock file is the normal way to update all of them.

Update every flake input:

```bash
nix flake update
```

After migrating from an old repository revision that used a mirror tarball for
`nixpkgs`, regenerate that input from the official GitHub branch once:

```bash
nix flake lock --update-input nixpkgs
```

Update one input only:

```bash
nix flake update home-manager
nix flake update nixpkgs
nix flake update nixos-hardware
```

Build the target host before switching:

```bash
nix build .#nixosConfigurations.ThinkPad-P14s.config.system.build.toplevel
```

Test activation without making it the boot default:

```bash
sudo nixos-rebuild test --flake .#ThinkPad-P14s
```

Switch after the build and test are clean:

```bash
sudo nixos-rebuild switch --flake .#ThinkPad-P14s
```

Commit the updated lock file after a successful test:

```bash
git add flake.lock
git commit -m "update flake inputs"
```

If a mirror is temporarily unavailable, retry later or change only the affected
input URL in `flake.nix`. Do not commit a lock update unless the target host can
build.

## Maintenance Notes

- Keep hardware files host-specific.
- Do not move disk layout or GPU quirks into common unless the same fact is true for every host.
- Do not hide boot mode inside common hardware config; choose `hosts/common/boot/legacy.nix` or `hosts/common/boot/uefi.nix` from each host.
- Prefer system packages for resources needed before login or by the display manager.
- Prefer Home Manager for user preferences, dotfiles, editor config, and per-user app config.
- Physical machines keep one main desktop environment but also include Niri + Noctalia as an alternate SDDM session.
- KDE dotfiles may require logout/login after rebuild.
- If KDE icons or cursors look wrong, verify both the config name and the package providing the resources.
- If `dbus-broker` errors return during `nixos-rebuild switch`, keep using `services.dbus.implementation = "dbus"`.
- `docker-test` is intentionally not a real desktop or installable machine profile.

## TODO

Tracked in [TODO.md](TODO.md):

- Nixvim configuration: done
- Yazi plugin integration: done

Near-term ideas:

- Continue refining KDE dotfile export/import coverage.
- Add more nixvim programming/tooling polish.
- Expand yazi configuration beyond the basic nixvim plugin.
- Keep programming and embedded toolchains in devShells unless a tool is genuinely needed before login.
