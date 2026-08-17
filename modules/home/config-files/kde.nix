/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-01
 * Description: Minimal Home Manager integration for KDE.
 *
 * Deliberately minimal: only the two-panel layout
 * (plasma-org.kde.plasma.desktop-appletsrc) and the locale file
 * (plasma-localerc) are linked. All other KDE state is left to Plasma
 * defaults. The old Arch-exported dotfiles (kdeglobals, kwinrc, plasmashellrc,
 * user feedback config, kdedefaults, ...) were removed on purpose.
 */
{ lib, pkgs, ... }:
let
  dotfilesRoot = ../../../dotfiles/kde;
  configRoot = dotfilesRoot + "/config";
  wallpapersRoot = dotfilesRoot + "/wallpapers";

  configFile = name: target:
    let
      source = configRoot + "/${name}";
    in
    lib.optionalAttrs (builtins.pathExists source) {
      "${target}" = {
        inherit source;
      };
    };
  wallpaperDir = lib.optionalAttrs (builtins.pathExists wallpapersRoot) {
    "wallpapers" = {
      source = wallpapersRoot;
    };
  };
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
    (configFile "plasma-org.kde.plasma.desktop-appletsrc" "plasma-org.kde.plasma.desktop-appletsrc")
    (configFile "plasma-localerc" "plasma-localerc")
  ];

  xdg.dataFile = lib.mkMerge [
    wallpaperDir
  ];
}
