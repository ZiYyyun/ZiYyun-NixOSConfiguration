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

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../modules/system/profiles/niri.nix
    ../../modules/system/services/flatpak
  ];

  services.displayManager.defaultSession = "niri";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
}
