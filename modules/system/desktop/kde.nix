/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE desktop enablement, session configuration, and desktop-specific packages.
 */
{ pkgs, ... }:
let
  # 面板歌词小部件（LRCLIB 数据源），配合顶部面板「歌词显示」使用。
  # 这是真正的第三方 plasmoid（Onlyrics），不是上游漏装补丁，单独打包。
  plasmoidOnlyrics = pkgs.callPackage ../../../packages/custom/source/plasmoid-onlyrics { };

  # ============================================================
  # QML applet 前端补装（根治 nixpkgs 26.05 plasma 漏装问题）
  # ============================================================
  # nixpkgs 26.05 (rev 02e08985) 构建 plasma-desktop/workspace/plasma-nm/
  # plasma-pa/bluedevil/kscreen 时漏装了各 applet 的 QML 前端
  # （share/plasma/plasmoids/<id> 只有 metadata.json，无 contents/ui），
  # 导致 plasmashell 报「软件包不存在」，面板/托盘小部件全挂。
  #
  # 根治：用 overlay 给这些包 overrideAttrs，在 postInstall 从构建源码
  # 目录 $sourceRoot 直接补装缺失的 QML。nixpkgs 构建时已给 metadata.json
  # 注入 "KPackageStructure": "Plasma/Applet"，因此这里只需补 contents/ui，
  # 不再覆盖 metadata（这正是之前补丁包手动 sed 注入字段的原因）。

  # 把若干 applet 源码目录的 QML 复制到 $out 的标准 KPackage 布局。
  promoteAppletQml = ''
    outP=$out/share/plasma/plasmoids
    # $1=源码里的 applet 目录  $2=plasmoid id
    promote() {
      local srcdir="$1" id="$2"
      local target="$outP/$id"
      mkdir -p "$target/contents/ui"
      if [ -d "$srcdir/qml" ]; then
        cp -r "$srcdir/qml/." "$target/contents/ui/"
      else
        cp "$srcdir"/*.qml "$target/contents/ui/" 2>/dev/null || true
        [ -d "$srcdir/code" ] && cp -r "$srcdir/code" "$target/contents/ui/"
      fi
      [ -f "$srcdir/main.xml" ] && {
        mkdir -p "$target/contents/config"
        cp "$srcdir/main.xml" "$target/contents/config/main.xml"
      }
    }
  '';

  # plasma-workspace 家族：从各自的源码目录补齐 QML。
  # 返回 postInstall 片段，借用 overrideAttrs 传入的 old 保留原 postInstall。
  makeQmlInstall = old: applets: old.postInstall + (''
    cd "$sourceRoot"
    outP=$out/share/plasma/plasmoids
    ${promoteAppletQml}
  '' + builtins.concatStringsSep "\n" (map (a: "promote ${a.src} ${a.id}") applets) + "\n");

  workspaceApplets = [
    { src = "applets/digital-clock"; id = "org.kde.plasma.digitalclock"; }
    { src = "applets/systemtray"; id = "org.kde.plasma.systemtray"; }
    { src = "applets/panelspacer"; id = "org.kde.plasma.panelspacer"; }
    { src = "applets/notifications"; id = "org.kde.plasma.notifications"; }
    { src = "applets/clipboard"; id = "org.kde.plasma.clipboard"; }
    { src = "applets/devicenotifier"; id = "org.kde.plasma.devicenotifier"; }
    { src = "applets/mediacontroller"; id = "org.kde.plasma.mediacontroller"; }
    { src = "applets/cameraindicator"; id = "org.kde.plasma.cameraindicator"; }
  ];

  plasmaNmApplets = [ { src = "applet"; id = "org.kde.plasma.networkmanagement"; } ];
  plasmaPaApplets = [ { src = "applet"; id = "org.kde.plasma.volume"; } ];
  bluedevilApplets = [ { src = "src/applet"; id = "org.kde.plasma.bluetooth"; } ];
  kscreenApplets = [ { src = "plasmoid"; id = "org.kde.kscreen"; } ];

  plasmaDesktopApplets = [
    { src = "applets/taskmanager"; id = "org.kde.plasma.taskmanager"; }
    { src = "applets/pager"; id = "org.kde.plasma.pager"; }
    { src = "applets/showdesktop"; id = "org.kde.plasma.showdesktop"; }
    { src = "applets/kickoff"; id = "org.kde.plasma.kickoff"; }
    { src = "applets/kicker"; id = "org.kde.plasma.kicker"; }
    { src = "applets/keyboardlayout"; id = "org.kde.plasma.keyboardlayout"; }
    { src = "applets/kimpanel"; id = "org.kde.plasma.kimpanel"; }
    { src = "applets/margins-separator"; id = "org.kde.plasma.marginsseparator"; }
    { src = "applets/showActivityManager"; id = "org.kde.plasma.showActivityManager"; }
    { src = "applets/window-list"; id = "org.kde.plasma.windowlist"; }
    { src = "applets/trash"; id = "org.kde.plasma.trash"; }
  ];
in
{
  # 用 overlay 根治上游 plasma 包漏装的 QML（关闭服务方 plasma6.enable 也生效）。
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages // {
        plasma-desktop = (prev.kdePackages.plasma-desktop).overrideAttrs (old: {
          postInstall =
            makeQmlInstall old plasmaDesktopApplets
            + ''
              # containment：org.kde.panel 面板容器（缺了它无法建面板）
              tgt=$out/share/plasma/containments/org.kde.panel
              mkdir -p "$tgt/contents/ui"
              cp -r containments/panel/*.qml "$tgt/contents/ui/" 2>/dev/null || true
              cp -r containments/panel/*.js "$tgt/contents/ui/" 2>/dev/null || true
              [ -f containments/panel/main.xml ] && {
                mkdir -p "$tgt/contents/config"
                cp containments/panel/main.xml "$tgt/contents/config/main.xml"
              }
            '';
        });
        plasma-workspace = (prev.kdePackages.plasma-workspace).overrideAttrs (old: {
          postInstall = makeQmlInstall old workspaceApplets;
        });
        plasma-nm = (prev.kdePackages.plasma-nm).overrideAttrs (old: {
          postInstall = makeQmlInstall old plasmaNmApplets;
        });
        plasma-pa = (prev.kdePackages.plasma-pa).overrideAttrs (old: {
          postInstall = makeQmlInstall old plasmaPaApplets;
        });
        bluedevil = (prev.kdePackages.bluedevil).overrideAttrs (old: {
          postInstall = makeQmlInstall old bluedevilApplets;
        });
        kscreen = (prev.kdePackages.kscreen).overrideAttrs (old: {
          postInstall = makeQmlInstall old kscreenApplets;
        });
      };
    })
  ];

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # KDE Connect：自动开放防火墙 TCP/UDP 1714-1764（手机配对/发现必需）。
  # 此前只装了 kdeconnect-kde 包但没启用模块，防火墙默认 drop 入站 → 手机无法发现电脑。
  programs.kdeconnect.enable = true;

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
    plasmoidOnlyrics
    plasma-panel-colorizer   # 社区插件：面板着色（顶栏右上角，替代歌词）
    kdePackages.yakuake
  ];
}