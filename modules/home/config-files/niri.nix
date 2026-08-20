/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Home Manager integration for Niri via out-of-store symlink.
 *
 * The repo file dotfiles/niri/config.kdl is symlinked straight into
 * ~/.config/niri/config.kdl (no Nix store copy), so editing it takes effect
 * immediately. Text editors that write in place (VS Code, vim) keep the
 * symlink; if a tool replaces it with a regular file, restore with
 * `home-manager switch`.
 */
{ config, lib, ... }:
let
  repoFile = "/home/ziyun/文档/GitHub/ZiYyun-NixOSConfiguration/dotfiles/niri/config.kdl";
in
{
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink repoFile;
}
