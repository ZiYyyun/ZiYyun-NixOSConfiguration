/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-01
 * Description: Optional Home Manager integration for repository-managed KDE dotfiles.
 *
 * Put exported KDE configuration files under:
 *   dotfiles/kde/config/
 *
 * Put repository-managed wallpapers under:
 *   dotfiles/kde/wallpapers/
 *
 * This module only links files that exist, so it is safe to enable while the
 * dotfiles directory is still being populated.
 *
 * plasma-org.kde.plasma.desktop-appletsrc restores the panel + desktop widget
 * layout exported from the previous Arch Linux setup (bottom panel with
 * kickoff/icon tasks, top panel with CPU/memory monitors, desktop disk-activity
 * widget). Wallpaper paths inside it point at dotfiles/kde/wallpapers.
 */
{ lib, pkgs, ... }:
let
  dotfilesRoot = ../../../dotfiles/kde;
  configRoot = dotfilesRoot + "/config";
  localShareRoot = dotfilesRoot + "/local-share";
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
  dataDir = name: target:
    let
      source = localShareRoot + "/${name}";
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
    (configFile "kdeglobals" "kdeglobals")
    (configFile "kwinrc" "kwinrc")
    (configFile "kglobalshortcutsrc" "kglobalshortcutsrc")
    (configFile "kcminputrc" "kcminputrc")
    (configFile "kscreenlockerrc" "kscreenlockerrc")
    (configFile "plasmarc" "plasmarc")
    (configFile "plasmashellrc" "plasmashellrc")
    (configFile "konsolerc" "konsolerc")
    (configFile "gtkrc" "gtkrc")
    (configFile "gtkrc-2.0" "gtkrc-2.0")
    (configFile "kscreen" "kscreen")
    (configFile "plasma-localerc" "plasma-localerc")
    (configFile "plasma-nm" "plasma-nm")
    (configFile "plasma-welcomerc" "plasma-welcomerc")
    (configFile "PlasmaDiscoverUpdates" "PlasmaDiscoverUpdates")
    (configFile "KDE" "KDE")
    (configFile "kde.org" "kde.org")
    (configFile "kdedefaults" "kdedefaults")
    (configFile "plasma-org.kde.plasma.desktop-appletsrc" "plasma-org.kde.plasma.desktop-appletsrc")
  ];

  xdg.dataFile = lib.mkMerge [
    (dataDir "aurorae" "aurorae")
    (dataDir "color-schemes" "color-schemes")
    (dataDir "desktoptheme" "desktoptheme")
    (dataDir "Kvantum" "Kvantum")
    (dataDir "look-and-feel" "look-and-feel")
    (dataDir "plasma" "plasma")
    wallpaperDir
  ];
}
