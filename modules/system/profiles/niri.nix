/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Niri host profile with Noctalia shell integration.
 *
 * 语义说明：profiles/ 是「桌面组合」层，desktop/ 是「原子桌面模块」层。
 * Niri 主会话 + 备用 Noctalia 组合成一个 profile，供 host 直接 import。
 */
{ ... }:
{
  imports = [
    ../desktop/niri.nix
    ../desktop/noctalia.nix
  ];
}
