/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Default KDE host profile.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../profiles/desktops/kde.nix
    ../../modules/system/services/flatpak.nix
  ];
}
