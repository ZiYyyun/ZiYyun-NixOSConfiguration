/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Default current-machine host profile.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak

    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/kde
    ../../modules/system/services/flatpak.nix
  ];
}
