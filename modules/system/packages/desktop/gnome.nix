/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: GNOME desktop application packages.
 */
{ config, pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    bottles
  ];
}
