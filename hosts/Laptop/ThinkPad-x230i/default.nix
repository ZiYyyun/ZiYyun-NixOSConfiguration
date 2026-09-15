/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Host profile for Lenovo ThinkPad X230i.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    # nixos-hardware does not provide a separate X230i profile; X230 is the
    # closest official ThinkPad profile for this generation.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230

    ../../common/hardware-configuration.nix
    ../../common/boot/legacy.nix
    ./hardware-configuration.nix
    ../../../modules/system/desktop/workstation.nix
    ../../../modules/system/hardware/thinkpad.nix
    ../../../modules/system/hardware/thinkpad-legacy.nix
    ../../../modules/system/services/flatpak.nix
  ];
}
