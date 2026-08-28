/**
 * File: dev.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: 开发/专业类 Flatpak 应用。
 */
{ ... }:

{
  services.flatpak.packages = [
    # 嵌入式/EDA
    "com.st.STM32CubeMX"
    "cn.lceda.LCEDAPro"
    "cc.arduino.IDE2"
    # 调试/分析
    "com.serial_studio.Serial-Studio"
    "org.wireshark.Wireshark"
    # AI 开发
    "com.cherry_ai.CherryStudio"
    # Flatpak 管理
    "com.github.tchx84.Flatseal"
    "org.dupot.easyflatpak"

    "com.zerobrane.studio"
  ];
}
