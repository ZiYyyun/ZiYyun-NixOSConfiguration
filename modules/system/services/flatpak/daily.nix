/**
 * File: daily.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: 日常/社交/娱乐类 Flatpak 应用。
 */
{ ... }:

{
  services.flatpak.packages = [
    # 社交
    "com.qq.QQ"
    "com.tencent.WeChat"
    "org.telegram.desktop"
    "com.discordapp.Discord"
    # 影音娱乐
    "com.spotify.Client"
    "io.github.qier222.YesPlayMusic"
    "com.obsproject.Studio"
    "com.valvesoftware.Steam"
    "org.gnome.SoundRecorder"
    # 网络/下载
    "org.torproject.torbrowser-launcher"
    "com.baidu.NetDisk"
    "org.freedownloadmanager.Manager"
    "org.desktop_plus.desktop-plus"
  ];
}
