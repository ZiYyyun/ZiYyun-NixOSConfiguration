/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Default GNOME host profile.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/gnome
    ../../modules/system/packages/desktop/niri
    ../../modules/system/packages/desktop/noctalia
    ../../modules/system/services/flatpak.nix
  ];
}
