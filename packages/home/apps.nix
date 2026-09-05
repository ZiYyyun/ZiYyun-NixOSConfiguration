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
    winetricks  # Wine 图形配置/主题管理（winecfg 之外，可装 win7/win10 视觉样式）
    #openclaw
    codex
    #cc-switch
    #wechat
    notepad-next
    vlc
    baidupcs-go
    mqttx            # MQTT 客户端（LuatOS/物联网调试通用）
    postman
    gerbv
    # Custom-packaged desktop apps (appear in the KDE application menu).
    customPackages.trae-code
    customPackages.feiq
    customPackages.redspider-student
    customPackages.qoder-cn
    customPackages.qoder-wake
    customPackages.codebuddy  # CodeBuddy IDE（腾讯 AI 编程 IDE）
    customPackages.qwen       # Qwen Studio（通义千问桌面客户端）
    customPackages.flex-movie # Flex Movie（跨平台媒体播放客户端）
    customPackages.webapps.doubao     # 豆包（浏览器 PWA）
    customPackages.webapps.qwen-chat  # 千问（浏览器 PWA）
    customPackages.webapps.deepseek   # DeepSeek（浏览器 PWA）
    customPackages.qoder-cli-cn  # Qoder CN 终端 AI 编程助手
    customPackages.luatools  # 合宙 LuatOS 官方调试/烧录工具（Wine）
  ];
}
