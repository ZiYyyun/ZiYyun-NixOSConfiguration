/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Host profile for Lenovo ThinkPad X230i.
 */
{ inputs, lib, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    # nixos-hardware does not provide a separate X230i profile; X230 is the
    # closest official ThinkPad profile for this generation.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/gnome
    ../../modules/system/packages/desktop/niri
    ../../modules/system/packages/desktop/noctalia
    ../../modules/system/packages/hardware/thinkpad
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
