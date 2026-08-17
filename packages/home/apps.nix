/**
 * File: apps.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: User-facing Home Manager package list.
 */
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spotify
    winboat
    clash-verge-rev
    mihomo
    obsidian
    koodo-reader
    microsoft-edge
    eudic
    libreoffice
    wine
    #openclaw
    codex
    #cc-switch
    #wechat
    notepad-next
    vlc
  ];
}
