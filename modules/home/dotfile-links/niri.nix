/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Home Manager integration for repository-managed Niri config.
 */
{ lib, ... }:
let
  config = ../../../assets/dotfiles/niri/config.kdl;
in
{
  xdg.configFile = lib.optionalAttrs (builtins.pathExists config) {
    "niri/config.kdl".source = config;
  };
}
