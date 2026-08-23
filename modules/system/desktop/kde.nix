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

  # 面板歌词小部件（LRCLIB 数据源），配合顶部面板「歌词显示」使用。
  plasmoidOnlyrics = pkgs.callPackage ../../../packages/custom/plasmoid-onlyrics { };
in
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    (fluent-icon-theme.override { colorVariants = [ "purple" ]; })
    candy-icons                # 二次元渐变彩色图标主题（kdeglobals 里切换）
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
    plasmoidOnlyrics
    kdePackages.yakuake
  ];
}
