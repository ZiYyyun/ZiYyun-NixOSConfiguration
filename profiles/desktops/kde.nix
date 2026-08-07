/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE host profile composed from KDE config and package modules.
 */
{ ... }:
{
  imports = [
    ../../modules/system/desktops/kde.nix
    ../../packages/system/desktops/kde.nix
    ../../modules/system/desktops/niri.nix
    ../../packages/system/desktops/niri.nix
    ../../modules/system/desktops/noctalia.nix
  ];
}
