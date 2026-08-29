/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE host profile.
 *
 * 语义说明：profiles/ 是「桌面组合」层，desktop/ 是「原子桌面模块」层。
 * host 只 import profiles/<name>.nix 即可得到一片组合好的桌面环境。
 * 若想调整某个桌面具体内容，去改 desktop/<name>.nix；若想改「组合进哪些
 * 桌面会话」，改这里。
 */
{ ... }:
{
  imports = [
    ../desktop/kde.nix
  ];
}
