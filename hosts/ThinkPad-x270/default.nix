/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Host profile for Lenovo ThinkPad X270.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x270

    ../common/hardware-configuration.nix
    ../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/gnome
    ../../modules/system/packages/desktop/niri
    ../../modules/system/packages/desktop/noctalia
    ../../modules/system/packages/hardware/thinkpad
    ../../modules/system/services/flatpak.nix
  ];
}
