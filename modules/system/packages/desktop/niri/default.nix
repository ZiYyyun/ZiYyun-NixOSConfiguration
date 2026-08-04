/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Niri Wayland compositor packages for TTY/manual sessions.
 */
{ pkgs, ... }:
{
  programs.niri.enable = true;

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
