/**
 * File: sddm.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Shared SDDM appearance settings.
 */
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.catppuccin-sddm ];

  services.displayManager.sddm = {
    theme = "catppuccin-mocha-mauve";
    extraPackages = [ pkgs.catppuccin-sddm ];
  };
}
