/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Niri host profile composed from Niri config and package modules.
 */
{ ... }:
{
  imports = [
    ../../modules/system/desktops/niri.nix
    ../../packages/system/desktops/niri.nix
    ../../modules/system/desktops/noctalia.nix
  ];
}
