/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: KDE desktop application packages.
 */
{ config, pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    (fluent-icon-theme.override { colorVariants = [ "purple" ]; })
    hicolor-icon-theme
    kdePackages.discover
    kdePackages.marble
    kdePackages.okular
    kdePackages.breeze-icons
    oreo-cursors-plus
  ];
}
