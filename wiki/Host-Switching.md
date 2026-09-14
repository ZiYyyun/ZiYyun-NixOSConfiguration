# Host Switching

This repository exposes multiple NixOS host entries from `flake.nix`.

## Available Hosts

| Host | Host File | Purpose |
|---|---|---|
| `niri-default` | `hosts/Dektop/niri-default/default.nix` | Generic Niri desktop |
| `desktop-default` | `hosts/Dektop/desktop-default/default.nix` | Generic KDE desktop |
| `x270` | `hosts/Laptop/ThinkPad-x270/default.nix` | Lenovo ThinkPad X270 |
| `x230` | `hosts/Laptop/ThinkPad-x230i/default.nix` | Lenovo ThinkPad X230i, using the official X230 profile |
| `p14s` | `hosts/Laptop/ThinkPad-P14s/default.nix` | Lenovo ThinkPad P14s Gen 5 Intel |
| `xiaomi-book-air13` | `hosts/Laptop/Xiaomi-Book-Air13/default.nix` | Xiaomi Book Air 13 (2022) |

## Test A Host

Use `test` before switching the real system:

```bash
sudo nixos-rebuild test --flake .#xiaomi-book-air13
```

## Switch A Host

After the test build succeeds:

```bash
sudo nixos-rebuild switch --flake .#xiaomi-book-air13
```

## Build Without Activating

Build a host's complete system closure without activating it:

```bash
nix build .#nixosConfigurations.xiaomi-book-air13.config.system.build.toplevel
```

## Hardware Profiles

The ThinkPad host files import profiles from `nixos-hardware`:

```nix
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x270
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
```

`x230` intentionally uses `lenovo-thinkpad-x230`, because `nixos-hardware` does not provide a separate X230i profile.

There is no upstream Xiaomi Book Air profile. That host composes the generic
Intel CPU, laptop, and SSD profiles, then applies device-specific settings from
`modules/system/hardware/xiaomi-book-air13.nix`.

For the current X230i disk layout, the NTFS disk labeled `系统` is not part of
the NixOS installation. The `x230` profile mounts root and swap by
UUID and installs legacy GRUB to `/dev/sdb`.
