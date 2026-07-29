/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: GNOME desktop application packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bottles
  ];
}
