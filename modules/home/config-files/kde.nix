/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-01
 * Description: Home Manager integration for KDE.
 *
 * Links the two-panel layout (plasma-org.kde.plasma.desktop-appletsrc), the
 * locale file (plasma-localerc), and the appearance/behavior settings that
 * were tuned in the running session and exported with
 * `shells/export-dotfiles.sh` (kdeglobals, kwinrc, plasmashellrc).
 *
 * Note: Home Manager links are read-only. If you tune Plasma again, Plasma
 * cannot persist changes into the store path; re-run the export script and
 * rebuild to pick them up.
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
    (configFile "kdeglobals" "kdeglobals")
    (configFile "kwinrc" "kwinrc")
    (configFile "plasmashellrc" "plasmashellrc")
  ];

  xdg.dataFile = lib.mkMerge [
    wallpaperDir
  ];
}
