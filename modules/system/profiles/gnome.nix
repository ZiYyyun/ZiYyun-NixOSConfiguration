/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME host profile with Niri and Noctalia available as alternate sessions.
 */
{ ... }:
{
  imports = [
    ../desktop/gnome.nix
    ../desktop/niri.nix
    ../desktop/noctalia.nix
  ];
}
