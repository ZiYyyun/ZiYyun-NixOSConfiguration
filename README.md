# ZiYyun NixOS Configuration

This repository is ziyun's personal NixOS flake. It keeps host profiles, desktop environments, hardware quirks, Home Manager user configuration, KDE/Niri dotfiles, Flatpak apps, development tools, and embedded dev shells in one reproducible place.

Current target release: **NixOS 26.05**.

## What Is Managed

| Area | Current State |
| --- | --- |
| Nix | Flakes enabled, `nix-command` enabled, `nixpkgs` pinned to `nixos-26.05` through the NJU Git mirror |
| Binary cache | USTC Nix binary cache first, official `cache.nixos.org` as fallback |
| User | Normal user `ziyun`, wheel/networkmanager groups, Home Manager enabled |
| Locale | `zh_CN.UTF-8`, timezone `Asia/Shanghai`, XKB layout `cn` |
| Network | NetworkManager, OpenSSH |
| Audio | PipeWire with ALSA, 32-bit ALSA, PulseAudio compatibility, RTKit |
| Printing | CUPS |
| Browser | Firefox through `programs.firefox.enable`; Microsoft Edge in Home Manager packages |
| Input method | Fcitx5 + Rime + Chinese addons, with GTK/Qt/X11 session variables |
| D-Bus | Reference `dbus-daemon` implementation, chosen because `dbus-broker` was unreliable during live rebuilds |
| Flatpak | `nix-flatpak`, Flathub via SJTU mirror, Tor Browser launcher installed |
| Home Manager | Git identity, user apps, VS Code Server, Ghostty config, KDE dotfiles, Niri config, nixvim |
| Editors | Nixvim/Neovim, VS Code, CLion, Eclipse Embedded CDT, Code::Blocks |
| Terminal | Ghostty installed and configured; VM may need software GL, real machines are the priority |
| Package GUIs | KDE Discover, GNOME Software, Warehouse, KDE Flatpak KCM, `nix-search-tv` |
| Desktop shells | KDE Plasma 6, GNOME, Niri, Noctalia |
| Theme resources | Catppuccin SDDM, Fluent purple icons, Breeze/hicolor icon fallback, Oreo purple cursor |
| Embedded | STM32, Espressif, PlatformIO, OpenOCD, probe-rs, serial tools, USB tools |

## Flake Inputs

| Input | Purpose |
| --- | --- |
| `nixpkgs` | Main package set, pinned to `nixos-26.05` through `git+https://mirrors.nju.edu.cn/git/nixpkgs.git` |
| `home-manager` | Home Manager release `26.05` |
| `nix-flatpak` | Declarative Flatpak remote and package management |
| `nixos-hardware` | Official hardware profiles for ThinkPads and desktop PC defaults |
| `nixos-vscode-server` | VS Code Remote server support through Home Manager |
| `noctalia` | Noctalia shell NixOS module |
| `nixvim` | Flake-based Neovim configuration |

`nixvim` is fetched through `git+https` instead of the GitHub flake shorthand to avoid GitHub API rate-limit pain.

## Host Outputs

| Flake output | Desktop/session | Hardware profile | Storage notes |
| --- | --- | --- | --- |
| `kde-default` | KDE Plasma 6 + SDDM, also includes Niri + Noctalia | none | VirtualBox/default KDE layout, root `/dev/sda2` |
| `niri-default` | Niri + Noctalia, SDDM default session set to Niri | none | VirtualBox/Niri layout, root `/dev/sda2`, VMware graphics workaround kept here |
| `gnome-default` | GNOME + GDM, also includes Niri + Noctalia | none | Default GNOME layout, root `/dev/sda2` |
| `desktop-default` | KDE Plasma 6 + SDDM, also includes Niri + Noctalia | `common-pc`, `common-pc-ssd` | Desktop PC layout, root `/dev/nvme0n1p2` |
| `ThinkPad-x270` | GNOME + GDM, also includes Niri + Noctalia | `lenovo-thinkpad-x270` | root `/dev/sda2` |
| `ThinkPad-x230i` | GNOME + GDM, also includes Niri + Noctalia | `lenovo-thinkpad-x230` | root `/dev/sda2` |
| `ThinkPad-P14s` | KDE Plasma 6 + SDDM, also includes Niri + Noctalia | `lenovo-thinkpad-p14s-intel-gen5` | USB-SATA SSD layout: GRUB on `/dev/sda`, root `/dev/sda1`, swap `/dev/sda2` |
| `docker-test` | no desktop | none | test-only fake root, no bootloader |

Hardware-specific disk and bootloader choices stay inside each host directory. They are intentionally not moved into `hosts/common`.

## Directory Map

```text
.
|-- flake.nix
|-- flake.lock
|-- configuration.nix
|-- hosts/
|   |-- common/
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
|   |   |-- packages/
|   |   |   |-- desktop/
|   |   |   |   |-- kde/
|   |   |   |   |-- gnome/
|   |   |   |   |-- niri/
|   |   |   |   `-- noctalia/
|   |   |   |-- development/
|   |   |   `-- hardware/
|   |   `-- services/
|   |       |-- dbus.nix
|   |       |-- input-method.nix
|   |       |-- sddm.nix
|   |       `-- flatpak.nix
|   `-- home-manager/
|       |-- home.nix
|       |-- nixvim.nix
|       `-- dotfiles/
|-- dotfiles/
|   |-- ghostty/
|   |-- kde/
|   `-- niri/
|-- shells/
|   |-- lib/
|   `-- targets/
|-- scripts/
|   |-- bootstrap.sh
|   |-- install.sh
|   `-- export-kde-dotfiles.sh
|-- wiki/
|   |-- Embedded-DevShells.md
|   `-- Host-Switching.md
`-- TODO.md
```

## System Modules

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
- base packages: `vim`, `wget`, `git`
- OpenSSH
- `system.stateVersion = "26.05"`

### Services

`modules/system/services/default.nix` imports:

- `dbus.nix`: sets `services.dbus.implementation = "dbus"`
- `input-method.nix`: Fcitx5, Rime, Chinese addons, config tool, input method environment variables
- `sddm.nix`: Catppuccin Mocha Mauve SDDM theme

`flatpak.nix` is imported only by host profiles that enable `nix-flatpak`.

### KDE

`modules/system/packages/desktop/kde/default.nix` enables:

- `services.xserver.enable`
- SDDM
- Plasma 6

It installs:

- KDE Discover
- Marble
- Okular
- Fluent icon theme, purple variant
- Breeze icons
- hicolor icon fallback
- Oreo cursor theme

### GNOME

`modules/system/packages/desktop/gnome/default.nix` enables:

- X server
- GDM
- GNOME

It currently installs `bottles`.

### Niri

`modules/system/packages/desktop/niri/default.nix` enables official NixOS Niri support:

- `programs.niri.enable = true`
- `programs.niri.package = pkgs.niri`
- graphics support
- XDG portals
- `xdg-desktop-portal-gtk`
- `xdg-desktop-portal-gnome`

Niri helper packages:

- `alacritty`
- `brightnessctl`
- `fuzzel`
- `grim`
- `mako`
- `networkmanagerapplet`
- `pavucontrol`
- `playerctl`
- `swaylock`
- `slurp`
- `swaybg`
- `swappy`
- `wl-clipboard`
- `xwayland-satellite`

### Noctalia

`modules/system/packages/desktop/noctalia/default.nix` enables Noctalia through the flake module:

```nix
programs.noctalia = {
  enable = true;
  recommendedServices.enable = true;
  systemd.enable = false;
};
```

`systemd.enable = false` is intentional. Noctalia is available, but it is not auto-started as a user service. The session config decides when to run it.

### ThinkPad Tools

`modules/system/packages/hardware/thinkpad/default.nix` installs:

- `tpacpi-bat`
- `hdapsd`

## Home Manager

Home Manager is wired in `flake.nix` and imports `modules/home-manager/home.nix`, nixvim's Home Manager module, and VS Code Server.

Home Manager currently manages:

- Git username/email
- user apps
- Ghostty config
- KDE dotfiles
- Niri config
- nixvim
- VS Code Server service

User applications in `home.packages`:

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

### KDE

KDE dotfiles live under:

```text
dotfiles/kde/
|-- config/
|-- local-share/
`-- wallpapers/
```

`modules/home-manager/dotfiles/kde.nix` links selected files and directories into the user's XDG config/data locations. It currently handles:

- `kdeglobals`
- `kwinrc`
- `kglobalshortcutsrc`
- `kcminputrc`
- `kscreenlockerrc` if present
- `plasma-org.kde.plasma.desktop-appletsrc`
- `plasmarc`
- `plasmashellrc`
- `konsolerc`
- `gtkrc`
- `gtkrc-2.0`
- `kscreen` if present
- `aurorae`
- `color-schemes` if present
- `desktoptheme` if present
- `Kvantum` if present
- `look-and-feel` if present
- `plasma`
- `wallpapers`

Current KDE theme resources include:

- icon theme configured as `Fluent-purple`
- cursor theme configured as `oreo_purple_cursors`, size `32`
- Layan Aurorae window decoration under `dotfiles/kde/local-share/aurorae`
- custom Plasma look-and-feel data under `dotfiles/kde/local-share/plasma`
- custom plasmoids, including `KdeControlStation` and `plasmusic-toolbar`

KDE does not provide a reliable built-in account sync for full desktop layout, icons, cursor, widgets, and local themes. KDE Store can install themes, but it does not reproduce the complete machine state. This repo uses the more reproducible route: Nix installs theme resources, Home Manager links the dotfiles.

To refresh KDE dotfiles from a configured machine, use:

```bash
./scripts/export-kde-dotfiles.sh
```

Then review the diff before committing. KDE config files can contain machine-specific screen IDs, absolute paths, and stale generated update markers.

### Niri

Niri config lives at:

```text
dotfiles/niri/config.kdl
```

Home Manager links it to:

```text
~/.config/niri/config.kdl
```

The current Niri config binds `Mod+T` to `ghostty`.

### Ghostty

Ghostty config lives at:

```text
dotfiles/ghostty/config
```

Home Manager links it to:

```text
~/.config/ghostty/config.ghostty
```

On VirtualBox, Ghostty may fail if the virtual GPU only exposes an old OpenGL version. The known workaround is:

```bash
LIBGL_ALWAYS_SOFTWARE=1 ghostty
```

The repository does not force this workaround globally because real hardware is the priority.

## Nixvim

`modules/home-manager/nixvim.nix` enables flake-based nixvim.

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

## System Packages

Shared development packages include:

- `rustc`
- `rustup`
- `cargo`
- `python3`
- `clang`
- `gcc`
- `gdb`
- `cmake`
- `gnumake`
- `ninja`
- `pkg-config`
- `perl`

General development and desktop tools include:

- `ghostty`
- `gnome-software`
- `kdePackages.flatpak-kcm`
- `nix-search-tv`
- `neovim`
- `vscode`
- `warehouse`
- `lmstudio`
- `docker`
- `jetbrains.clion`
- `eclipses.eclipse-embedcpp`
- `stm32cubemx`
- `kicad`
- `codeblocks`
- `filezilla`

Commented or reserved packages:

- `trae`
- `claude-code`
- `.NET` runtimes
- `steam`
- `wechat`

## Embedded Development

Shared embedded packages:

- `openocd`
- `probe-rs-tools`
- `dfu-util`
- `libusb1`
- `minicom`
- `picocom`
- `screen`
- `usbutils`
- `platformio`

Vendor modules imported into the shared system profile:

- Espressif: `esphome`, `esptool`, `espflash`
- STM32: `stm32flash`, `stlink`

Vendor modules kept available but not imported globally:

- Nordic: `nrf-command-line-tools`, `nrfconnect`, `nrf5-sdk`, `nrf-udev`, `nrfutil`
- Allwinner: `sunxi-tools`, `xfel`

Nordic is kept out of the shared system profile because one dependency path still pulls obsolete Qt4. Allwinner tools are currently used through dev shells instead of the global profile.

## Dev Shells

Flake dev shells are defined under `shells/targets/`.

```bash
nix develop .#stm
nix develop .#esp
nix develop .#nordic
nix develop .#arm32
nix develop .#arm64
nix develop .#allwinner
nix develop .#rockchip
```

`devShells.default` points to the STM shell.

Details are in [wiki/Embedded-DevShells.md](wiki/Embedded-DevShells.md).

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

## Install From Live ISO

Boot into a NixOS live ISO, connect to the network, then run:

```bash
curl -L https://raw.githubusercontent.com/ZiYyyun/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash
```

The default path assumes you already partitioned, formatted, and mounted the target system at `/mnt`. The installer prepares the repo under `/mnt/etc/nixos` and installs the default flake output.

To specify a disk without erasing it:

```bash
curl -L https://raw.githubusercontent.com/ZiYyyun/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash -s -- -- --disk /dev/nvme0n1
```

To erase, partition, format, and mount a disk, pass `--erase` explicitly:

```bash
curl -L https://raw.githubusercontent.com/ZiYyyun/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash -s -- -- --disk /dev/sda --erase
```

The script asks for an explicit confirmation such as:

```text
ERASE /dev/sda
```

To prepare files but skip installation:

```bash
sudo bash scripts/install.sh --mountpoint /mnt --skip-install
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

## Mirrors

| Component | Mirror |
| --- | --- |
| nixpkgs Git input | NJU, `https://mirrors.nju.edu.cn/git/nixpkgs.git` |
| Nix binary cache | USTC, `https://mirrors.ustc.edu.cn/nix-channels/store` |
| Nix official fallback | `https://cache.nixos.org/` |
| Flatpak | SJTU Flathub mirror |

Temporary rebuild with explicit substituters:

```bash
sudo nixos-rebuild switch --flake .#ThinkPad-P14s --option substituters "https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
```

## Updating Inputs

Update one input:

```bash
nix flake lock --update-input home-manager
```

Update the lock file:

```bash
nix flake lock
```

Check evaluation:

```bash
nix flake check
```

If GitHub rate limits appear while updating GitHub-backed inputs, change proxy/IP and retry. The `nixvim` input already uses Git transport to reduce API pressure.

## Maintenance Notes

- Keep hardware files host-specific.
- Do not move disk layout, bootloader selection, or GPU quirks into common unless the same fact is true for every host.
- Prefer system packages for resources needed before login or by the display manager.
- Prefer Home Manager for user preferences, dotfiles, editor config, and per-user app config.
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
- Add more nixvim language/tooling polish.
- Expand yazi configuration beyond the basic nixvim plugin.
- Add heavier SDK shells only where they do not poison the global system profile.
