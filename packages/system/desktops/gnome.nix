/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME desktop package set.
 */
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bottles
  ];
}
