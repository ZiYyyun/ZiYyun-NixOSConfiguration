/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE desktop enablement, session configuration, and desktop-specific packages.
 */
{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    (fluent-icon-theme.override { colorVariants = [ "purple" ]; })
    hicolor-icon-theme
    kdePackages.bluedevil
    kdePackages.kdeconnect-kde
    kdePackages.kdeplasma-addons
    kdePackages.kscreen
    kdePackages.plasma-nm
    kdePackages.plasma-pa
    kdePackages.plasma-systemmonitor
    kdePackages.plasma-vault
    kdePackages.powerdevil
    kdePackages.print-manager
    kdePackages.discover
    kdePackages.marble
    kdePackages.okular
    kdePackages.breeze-icons
    oreo-cursors-plus
  ];
}
