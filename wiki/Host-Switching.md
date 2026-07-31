# Host Switching

This repository exposes multiple NixOS host entries from `flake.nix`.

## Available Hosts

| Host | Host File | Purpose |
|---|---|---|
| `nixos` | `modules/system/packages/hosts/hardware-configuration.nix` | Default current machine configuration |
| `docker-test` | `modules/system/packages/hosts/docker.nix` | Build/evaluation test profile without Flatpak or real bootloader/disk assumptions |
| `ThinkPad-x270` | `modules/system/packages/hosts/ThinkPad-x270.nix` | Lenovo ThinkPad X270 |
| `ThinkPad-x230i` | `modules/system/packages/hosts/ThinkPad-x230i.nix` | Lenovo ThinkPad X230i, using the official X230 profile |
| `ThinkPad-P14s` | `modules/system/packages/hosts/ThinkPad-P14s.nix` | Lenovo ThinkPad P14s Gen 5 Intel |

## Test A Host

Use `test` before switching the real system:

```bash
sudo nixos-rebuild test --flake .#ThinkPad-P14s
```

## Switch A Host

After the test build succeeds:

```bash
sudo nixos-rebuild switch --flake .#ThinkPad-P14s
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

`ThinkPad-x230i` intentionally uses `lenovo-thinkpad-x230`, because `nixos-hardware` does not provide a separate X230i profile.
