/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME host profile composed from GNOME config and package modules.
 */
{ ... }:
{
  imports = [
    ../../modules/system/desktops/gnome.nix
    ../../packages/system/desktops/gnome.nix
    ../../modules/system/desktops/niri.nix
    ../../packages/system/desktops/niri.nix
    ../../modules/system/desktops/noctalia.nix
  ];
}
