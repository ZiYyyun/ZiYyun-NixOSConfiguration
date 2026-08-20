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
    ../common/boot/uefi.nix
    ./hardware-configuration.nix
    ../../modules/system/profiles/kde.nix
    ../../packages/system/hardware/thinkpad.nix
    ../../modules/system/profiles/niri.nix
    ../../modules/system/services/flatpak
    ../../modules/system/services/winboat.nix
    ../../modules/system/services/fprintd.nix
    ../../modules/system/services/waydroid.nix
  ];
}
