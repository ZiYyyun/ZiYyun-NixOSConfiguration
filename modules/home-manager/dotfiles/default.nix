/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Optional Home Manager dotfiles module entrypoint.
 */
{ ... }:
{
  imports = [
    ./ghostty.nix
    ./kde.nix
    ./niri.nix
  ];
}
