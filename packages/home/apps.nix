/**
 * File: apps.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: User-facing Home Manager package list.
 */
{ pkgs, customPackages, ... }:
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
    # Custom-packaged desktop apps (appear in the KDE application menu).
    customPackages.trae-code
    customPackages.feiq
    customPackages.redspider-student
    customPackages.qoder-cn
    customPackages.qoder-wake
    customPackages.luatools  # 合宙 LuatOS 官方调试/烧录工具（Wine）
  ];
}
