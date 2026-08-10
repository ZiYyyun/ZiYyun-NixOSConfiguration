/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Niri Wayland compositor enablement, portal settings, and helper applications.
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

  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    fuzzel
    grim
    mako
    networkmanagerapplet
    pavucontrol
    playerctl
    swaylock
    slurp
    swaybg
    swappy
    wl-clipboard
    xwayland-satellite
  ];
}
