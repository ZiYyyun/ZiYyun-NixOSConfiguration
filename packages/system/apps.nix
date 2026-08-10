/**
 * File: apps.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: General desktop/system applications installed globally.
 */
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ghostty
    gnome-software
    kdePackages.flatpak-kcm
    nix-search-tv
    warehouse
    lmstudio
    docker
    filezilla
  ];
}
