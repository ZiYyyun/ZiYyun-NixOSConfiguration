/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Default Niri + Noctalia host profile.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak

    ../../common/hardware-configuration.nix
    ../../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../../modules/system/desktop/workstation.nix
    ../../../modules/system/services/flatpak.nix
  ];
}
