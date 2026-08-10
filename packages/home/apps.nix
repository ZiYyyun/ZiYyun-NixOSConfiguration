/**
 * File: apps.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: User-facing Home Manager package list.
 */
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    honeyfetch
    spotify
    winboat
    clash-verge-rev
    obsidian
    koodo-reader
    qq
    microsoft-edge
    eudic
    libreoffice
    wine
  ];
}
