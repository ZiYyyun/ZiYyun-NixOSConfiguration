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

  # plasma-workspace/plasma-nm/plasma-pa 的 applet QML 同样被 nixpkgs 26.05
  # 漏装（digitalclock/systemtray/panelspacer/networkmanagement/volume...），
  # 与 plasma-desktop-qml 互补，缺了它们 plasmashell 会大面积报「软件包不存在」。
  plasmaWorkspaceQml = pkgs.callPackage ../../../packages/custom/plasma-workspace-qml { };
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
    plasmaWorkspaceQml
    plasmoidOnlyrics
    plasma-panel-colorizer   # 社区插件：面板着色（顶栏右上角，替代歌词）
    kdePackages.yakuake
  ];
}
