/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE host profile with Niri and Noctalia available as alternate sessions.
 */
{ ... }:
{
  imports = [
    ../desktop/kde.nix
    ../desktop/niri.nix
    ../desktop/noctalia.nix
  ];
}
