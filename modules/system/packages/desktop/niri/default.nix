/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Niri Wayland compositor profile.
 */
{ pkgs, ... }:
{
  programs.niri.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "niri";

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
    slurp
    swaybg
    swappy
    wl-clipboard
    xwayland-satellite
  ];
}
