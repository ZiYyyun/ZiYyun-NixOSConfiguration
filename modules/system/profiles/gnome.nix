/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME host profile with Niri and Noctalia available as alternate sessions.
 *
 * 语义说明：profiles/ 是「桌面组合」层，desktop/ 是「原子桌面模块」层。
 * 这里把主 GNOME + 备用 Niri/Noctalia 组合成一个 profile，供 host 直接 import。
 */
{ ... }:
{
  imports = [
    ../desktop/gnome.nix
    ../desktop/niri.nix
    ../desktop/noctalia.nix
  ];
}
