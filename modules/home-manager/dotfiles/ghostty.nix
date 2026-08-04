/**
 * File: ghostty.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Home Manager integration for Ghostty terminal config.
 */
{ lib, ... }:
let
  config = ../../../dotfiles/ghostty/config;
in
{
  xdg.configFile = lib.optionalAttrs (builtins.pathExists config) {
    "ghostty/config.ghostty".source = config;
  };
}
