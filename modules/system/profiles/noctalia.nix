/**
 * File: noctalia.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Noctalia host profile.
 *
 * 语义说明：profiles/ 是「桌面组合」层，desktop/ 是「原子桌面模块」层。
 * noctalia 单独成 profile，若 host 想要 Noctalia 会话需显式 import。
 */
{ ... }:
{
  imports = [
    ../desktop/noctalia.nix
  ];
}
