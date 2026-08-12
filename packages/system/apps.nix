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
    docker
    filezilla
    # LM Studio is a large AppImage fetched from the vendor CDN. Keep it out of
    # the default rebuild path until we move heavyweight GUI apps to an optional
    # package profile.
    # lmstudio
  ];
}
