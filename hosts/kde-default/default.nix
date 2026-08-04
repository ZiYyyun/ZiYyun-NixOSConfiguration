/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Default interactive desktop profile, currently Niri + Noctalia.
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak

    ../common/hardware-configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/packages/desktop/niri
    ../../modules/system/packages/desktop/noctalia
    ../../modules/system/services/flatpak.nix
  ];
}
