/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Niri helper applications.
 */
{ pkgs, ... }:
{
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
