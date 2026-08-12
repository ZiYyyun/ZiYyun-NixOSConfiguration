/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Host profile for Lenovo ThinkPad P14s Gen 5 Intel.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../modules/system/profiles/kde.nix
    ../../packages/system/hardware/thinkpad.nix
    ../../modules/system/services/flatpak.nix
    ../../modules/system/services/winboat.nix
  ];
}
