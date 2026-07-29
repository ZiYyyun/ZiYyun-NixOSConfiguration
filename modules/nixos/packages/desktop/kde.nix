/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: KDE desktop application packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdePackages.discover
    kdePackages.marble
    kdePackages.okular
  ];
}
