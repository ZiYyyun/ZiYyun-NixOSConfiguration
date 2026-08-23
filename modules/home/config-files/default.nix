/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Home Manager entrypoint for repository-managed config file links.
 */
{ ... }:
{
  imports = [
    ./ghostty.nix
    ./kde.nix
    ./niri.nix
    ./noctalia.nix
    ./user-dirs.nix
  ];
}
