/**
 * File: noctalia.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Noctalia enablement.
 */
{ ... }:
{
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = false;
  };
}
