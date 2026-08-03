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
    ../../modules/system/packages/desktop/kde
    ../../modules/system/services/flatpak.nix
  ];
}
