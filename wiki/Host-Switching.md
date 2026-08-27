# Host Switching

This repository exposes multiple NixOS host entries from `flake.nix`.

## Available Hosts

| Host | Host File | Purpose |
|---|---|---|
| `kde-default` | `hosts/kde-default/default.nix` | Default KDE profile for a new/current machine |
| `gnome-default` | `hosts/gnome-default/default.nix` | Default GNOME profile for a new/current machine |
| `docker-test` | `hosts/docker-test/default.nix` | Build/evaluation test profile without Flatpak or real bootloader/disk assumptions |
| `x270` | `hosts/ThinkPad-x270/default.nix` | Lenovo ThinkPad X270 |
| `x230` | `hosts/ThinkPad-x230i/default.nix` | Lenovo ThinkPad X230i, using the official X230 profile |
| `p14s` | `hosts/ThinkPad-P14s/default.nix` | Lenovo ThinkPad P14s Gen 5 Intel |
| `cloud-server` | `hosts/cloud-server/default.nix` | 云服务器（headless，x86_64，UEFI）；部署前先按 hardware-configuration.nix 注释填好磁盘布局 |

## Test A Host

Use `test` before switching the real system:

```bash
sudo nixos-rebuild test --flake .#kde-default
```

## Switch A Host

After the test build succeeds:

```bash
sudo nixos-rebuild switch --flake .#kde-default
```

## Build The Docker Test Profile

When `nix-flatpak` blocks evaluation, test the rest of the configuration with:

```bash
nix build .#nixosConfigurations.docker-test.config.system.build.toplevel
```

## Hardware Profiles

The ThinkPad host files import profiles from `nixos-hardware`:

```nix
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x270
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
```

`x230` intentionally uses `lenovo-thinkpad-x230`, because `nixos-hardware` does not provide a separate X230i profile.

For the current X230i disk layout, the NTFS disk labeled `系统` is not part of
the NixOS installation. The `x230` profile mounts root and swap by
UUID and installs legacy GRUB to `/dev/sdb`.
