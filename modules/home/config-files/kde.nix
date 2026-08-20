/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-01
 * Description: Home Manager integration for KDE via out-of-store symlinks.
 *
 * Uses config.lib.file.mkOutOfStoreSymlink so the managed files are symlinked
 * directly to the repository dotfiles (NOT copied into the Nix store):
 * editing the repo file takes effect immediately, no rebuild needed.
 *
 * Caveat: KDE apps save config atomically (temp file + rename), which replaces
 * the symlink with a regular file. After changing settings inside a KDE app,
 * the link is broken; restore it with `home-manager switch` (your manual
 * changes are kept next to it as *.hm-backup) or copy the file back into the
 * repo first if you want to keep the new values.
 */
{ config, lib, pkgs, ... }:
let
  # Absolute path to this repository's KDE dotfiles (out-of-store link target).
  dotfilesRoot = "/home/ziyun/文档/GitHub/ZiYyun-NixOSConfiguration/dotfiles";
  configRoot = "${dotfilesRoot}/kde/config";
  wallpapersRoot = "${dotfilesRoot}/kde/wallpapers";

  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.pointerCursor = {
    package = pkgs.oreo-cursors-plus;
    name = "oreo_purple_cursors";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile = lib.mkMerge [
    {
      "plasma-org.kde.plasma.desktop-appletsrc".source = link "${configRoot}/plasma-org.kde.plasma.desktop-appletsrc";
      "plasma-localerc".source = link "${configRoot}/plasma-localerc";
      "kdeglobals".source = link "${configRoot}/kdeglobals";
      "kwinrc".source = link "${configRoot}/kwinrc";
      "plasmashellrc".source = link "${configRoot}/plasmashellrc";
    }
  ];

  xdg.dataFile = lib.mkMerge [
    {
      "wallpapers".source = link wallpapersRoot;
    }
  ];
}
