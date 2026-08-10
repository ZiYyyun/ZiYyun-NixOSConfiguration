/**
 * File: niri.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Niri host profile with Noctalia shell integration.
 */
{ ... }:
{
  imports = [
    ../desktop/niri.nix
    ../desktop/noctalia.nix
  ];
}
