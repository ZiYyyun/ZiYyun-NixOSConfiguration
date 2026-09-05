/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Root package entrypoint for all system-level package groups.
 */
{ ... }:
{
  imports = [
    ./base.nix
    ./apps.nix
    ./development.nix
    ./flatpak
  ];
}
