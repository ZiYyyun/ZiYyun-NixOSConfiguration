/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Default KDE host profile with Niri + Noctalia available from TTY.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak

    ../common/hardware-configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/kde
    ../../modules/system/packages/desktop/niri
    ../../modules/system/packages/desktop/noctalia
    ../../modules/system/services/flatpak.nix
  ];
}
