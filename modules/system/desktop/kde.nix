/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE desktop enablement, session configuration, and desktop-specific packages.
 */
{ pkgs, ... }:
let
  # nixpkgs 26.05 的 plasma-desktop 构建漏装 applet QML，用补丁包补上
  # （taskmanager/icontasks/kickoff/windowlist 等小部件缺 contents/ui）。
  plasmaDesktopQml = pkgs.callPackage ../../../packages/custom/plasma-desktop-qml { };
in
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
    plasmaDesktopQml
    kdePackages.yakuake
  ];
}
