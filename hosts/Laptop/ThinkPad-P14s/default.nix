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


    ../../common/hardware-configuration.nix
    ../../common/boot/uefi.nix
    ./hardware-configuration.nix
    ../../../modules/system/desktop/kde.nix
    ../../../modules/system/hardware/thinkpad.nix
    ./nvidia.nix
    ../../../modules/system/desktop/niri.nix
    ../../../modules/system/desktop/noctalia.nix
    ../../../modules/system/services/flatpak.nix
    ../../../modules/system/services/winboat.nix
    ../../../modules/system/services/fprintd.nix
    ../../../modules/system/services/waydroid.nix
  ];
}
