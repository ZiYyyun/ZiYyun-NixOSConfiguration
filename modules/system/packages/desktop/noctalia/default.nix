/**
 * File: noctalia.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Noctalia shell configuration.
 */
{ ... }:
{
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = false;
  };
}
