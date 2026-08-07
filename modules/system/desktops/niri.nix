/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Niri Wayland compositor enablement and portal settings.
 */
{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
  };

  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
