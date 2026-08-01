/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-01
 * Description: Optional Home Manager integration for repository-managed KDE dotfiles.
 *
 * Put exported KDE configuration files under:
 *   dotfiles/kde/config/
 *
 * Put wallpapers under:
 *   dotfiles/kde/wallpapers/
 *
 * This module only links files that exist, so it is safe to enable while the
 * dotfiles directory is still being populated.
 */
{ lib, ... }:
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
in
{
  xdg.configFile = lib.mkMerge [
    (configFile "kdeglobals" "kdeglobals")
    (configFile "kwinrc" "kwinrc")
    (configFile "kglobalshortcutsrc" "kglobalshortcutsrc")
    (configFile "kcminputrc" "kcminputrc")
    (configFile "kscreenlockerrc" "kscreenlockerrc")
    (configFile "plasma-org.kde.plasma.desktop-appletsrc" "plasma-org.kde.plasma.desktop-appletsrc")
    (configFile "plasmarc" "plasmarc")
    (configFile "konsolerc" "konsolerc")
  ];

  home.file = lib.optionalAttrs (builtins.pathExists wallpapersRoot) {
    ".local/share/wallpapers".source = wallpapersRoot;
  };
}
