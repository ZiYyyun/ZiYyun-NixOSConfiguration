/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Default desktop PC profile.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../common/hardware-configuration.nix
    ../../common/boot/uefi.nix
    ./hardware-configuration.nix
    ../../../modules/system/desktop/kde.nix
    ../../../modules/system/services/flatpak.nix
  ];
}
