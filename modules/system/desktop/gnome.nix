/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME desktop enablement, session configuration, and desktop-specific packages.
 */
{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    bottles
  ];
}
