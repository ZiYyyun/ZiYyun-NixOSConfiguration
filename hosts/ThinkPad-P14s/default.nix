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

    ../common/hardware-configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/kde
    ../../modules/system/packages/hardware/thinkpad
    ../../modules/system/services/flatpak.nix
  ];
}
