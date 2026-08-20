/**
* File: ghostty.nix
* Author: ziyun
* Date: 2026-08-04
* Description: Home Manager integration for Ghostty via out-of-store symlink.
*
* dotfiles/ghostty/config is symlinked to ~/.config/ghostty/config.ghostty
* directly (no Nix store copy), so editing the repo file takes effect
* immediately. Note the odd target name is intentional: `config.ghostty` is
* Ghostty's own config file name.
*/
{ config, ... }:
let
  repoFile = "/home/ziyun/文档/GitHub/ZiYyun-NixOSConfiguration/dotfiles/ghostty/config";
in
{
  xdg.configFile."ghostty/config.ghostty".source = config.lib.file.mkOutOfStoreSymlink repoFile;
}
