/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME desktop enablement and session configuration.
 */
{ ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}
