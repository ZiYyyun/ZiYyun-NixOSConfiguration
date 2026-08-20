/**
 * File: apps.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: User-facing Home Manager package list.
 */
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    winboat
    clash-verge-rev
    mihomo
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
    baidupcs-go
    mqttx            # MQTT 客户端（LuatOS/物联网调试通用）
    postman
  ];
}
