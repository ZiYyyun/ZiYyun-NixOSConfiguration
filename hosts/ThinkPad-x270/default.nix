/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Host profile for Lenovo ThinkPad X270.
 */
{ inputs, lib, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x270

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../profiles/desktops/gnome.nix
    ../../packages/system/hardware/thinkpad.nix
    ../../modules/system/services/flatpak.nix
  ];

  # Keep GNOME installed, but use SDDM as the session picker so Niri is
  # available alongside the main desktop environment on real hardware.
  services.displayManager.gdm.enable = lib.mkForce false;
  services.displayManager.sddm = {
    enable = lib.mkForce true;
    wayland.enable = lib.mkForce false;
  };
}
