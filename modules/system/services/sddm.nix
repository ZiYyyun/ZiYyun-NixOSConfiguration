/**
 * File: sddm.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Shared SDDM appearance settings.
 */
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    theme = "catppuccin-mocha-mauve";
    extraPackages = [ pkgs.catppuccin-sddm ];
  };
}
