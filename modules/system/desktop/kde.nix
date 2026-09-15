/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: KDE desktop enablement, session configuration, and desktop-specific packages.
 */
{ pkgs, lib, ... }:
let
  # ============================================================
  # QML applet 前端补装（根治 nixpkgs 26.05 plasma 漏装问题）
  # ============================================================
  # nixpkgs 26.05 的 Plasma 6.6.6 构建 plasma-desktop/workspace/plasma-nm/
  # plasma-pa/bluedevil/kscreen 时把各 applet 的 plasmoid 目录整个漏装了
  # （share/plasma/plasmoids/<id> 完全不存在，连 metadata.json 都没有），
  # 导致 plasmashell 报「软件包不存在」，面板/托盘小部件全挂。
  #
  # 根治：用 overlay 给这些包 overrideAttrs，在 postInstall 从 $src
  # （原包源码 tarball，绝对路径、无 cwd 依赖）解压出各 applet 的
  # plasmoid 目录并完整安装（metadata.json + contents/ui + config），
  # 并注入 "KPackageStructure": "Plasma/Applet"（nixpkgs 正常构建时会加
  # 这个字段，缺失会导致 plasmashell 拒绝加载）。

  # 从解压好的源码根目录复制 applet 的标准 plasmoid 布局：
  # metadata.json + contents/ui/*.qml + contents/config/main.xml。
  # $1=源码里 applet 目录  $2=plasmoid id
  promoteApplet = ''
    promote() {
      local srcdir="$1" id="$2"
      local target="$outP/$id"
      # Newer nixpkgs may package the applet correctly. Never overwrite an
      # upstream copy from the same Plasma build.
      if [ -f "$target/metadata.json" ] && \
         find "$target/contents/ui" -type f -name '*.qml' -print -quit 2>/dev/null | grep -q .; then
        return 0
      fi
      mkdir -p "$target/contents/ui" "$target/contents/config"
      # metadata.json
      [ -f "$srcdir/metadata.json" ] && cp "$srcdir/metadata.json" "$target/"
      # QML 前端：优先 contents/ui（已是打包布局），否则 qml/ 子目录铺平。
      if [ -d "$srcdir/contents/ui" ]; then
        cp -r "$srcdir/contents/ui/." "$target/contents/ui/"
      elif [ -d "$srcdir/qml" ]; then
        cp -r "$srcdir/qml/." "$target/contents/ui/"
      else
        cp "$srcdir"/*.qml "$target/contents/ui/" 2>/dev/null || true
      fi
      # code/ 等额外 QML 源
      [ -d "$srcdir/code" ] && cp -r "$srcdir/code" "$target/contents/"
      # main.xml → contents/config/
      if [ -f "$srcdir/main.xml" ]; then
        cp "$srcdir/main.xml" "$target/contents/config/main.xml"
      fi
      # 注入 KPackageStructure（缺失会导致 plasmashell 拒绝加载）。
      if [ -f "$target/metadata.json" ] && ! grep -q '"KPackageStructure"' "$target/metadata.json"; then
        sed -i '1s/^{/{\n    "KPackageStructure": "Plasma\/Applet",/' "$target/metadata.json"
      fi
      test -f "$target/metadata.json"
      find "$target/contents/ui" -type f -name '*.qml' -print -quit | grep -q .
    }
  '';

  # 生成某个包的 postInstall：解压 $src 到 $srcdir，promote 各 applet。
  # applets: [ { srcdir = "applets/kickoff"; id = "org.kde.plasma.kickoff"; } ]
  makeQmlInstall = old: applets: (old.postInstall or "") + (let
    promotes = builtins.concatStringsSep "\n" (map (a: "promote ${a.srcdir} ${a.id}") applets);
  in ''
    # 解压源码到当前 derivation 的临时目录，不依赖当前工作目录。
    srcDir="$TMPDIR/plasma-fix-src"
    rm -rf "$srcDir" && mkdir -p "$srcDir"
    tar xf "$src" -C "$srcDir" --strip-components=1 || { echo "plasma-fix: tar failed for $src"; exit 1; }
    cd "$srcDir"
    outP=$out/share/plasma/plasmoids
    ${promoteApplet}
    ${promotes}
  '');

  workspaceApplets = [
    { srcdir = "applets/digital-clock"; id = "org.kde.plasma.digitalclock"; }
    { srcdir = "applets/systemtray"; id = "org.kde.plasma.systemtray"; }
    { srcdir = "applets/panelspacer"; id = "org.kde.plasma.panelspacer"; }
    { srcdir = "applets/notifications"; id = "org.kde.plasma.notifications"; }
    { srcdir = "applets/clipboard"; id = "org.kde.plasma.clipboard"; }
    { srcdir = "applets/devicenotifier"; id = "org.kde.plasma.devicenotifier"; }
    { srcdir = "applets/mediacontroller"; id = "org.kde.plasma.mediacontroller"; }
    { srcdir = "applets/cameraindicator"; id = "org.kde.plasma.cameraindicator"; }
  ];

  plasmaNmApplets = [ { srcdir = "applet"; id = "org.kde.plasma.networkmanagement"; } ];
  plasmaPaApplets = [ { srcdir = "applet"; id = "org.kde.plasma.volume"; } ];
  bluedevilApplets = [ { srcdir = "src/applet"; id = "org.kde.plasma.bluetooth"; } ];
  kscreenApplets = [ { srcdir = "plasmoid"; id = "org.kde.kscreen"; } ];

  plasmaDesktopApplets = [
    { srcdir = "applets/taskmanager"; id = "org.kde.plasma.taskmanager"; }
    { srcdir = "applets/pager"; id = "org.kde.plasma.pager"; }
    { srcdir = "applets/showdesktop"; id = "org.kde.plasma.showdesktop"; }
    { srcdir = "applets/kickoff"; id = "org.kde.plasma.kickoff"; }
    { srcdir = "applets/kicker"; id = "org.kde.plasma.kicker"; }
    { srcdir = "applets/keyboardlayout"; id = "org.kde.plasma.keyboardlayout"; }
    { srcdir = "applets/kimpanel"; id = "org.kde.plasma.kimpanel"; }
    { srcdir = "applets/margins-separator"; id = "org.kde.plasma.marginsseparator"; }
    { srcdir = "applets/showActivityManager"; id = "org.kde.plasma.showActivityManager"; }
    { srcdir = "applets/window-list"; id = "org.kde.plasma.windowlist"; }
    { srcdir = "applets/trash"; id = "org.kde.plasma.trash"; }
  ];

  # org.kde.panel 面板容器（缺了它 plasmashell 无法创建任何面板）。
  panelFix = ''
    tgt=$out/share/plasma/containments/org.kde.panel
    if ! { [ -f "$tgt/metadata.json" ] && \
           find "$tgt/contents/ui" -type f -name '*.qml' -print -quit 2>/dev/null | grep -q .; }; then
      srcDir="$TMPDIR/plasma-fix-src"
      rm -rf "$srcDir" && mkdir -p "$srcDir"
      tar xf "$src" -C "$srcDir" --strip-components=1
      mkdir -p "$tgt/contents/ui"
      cp -r "$srcDir/containments/panel/"*.qml "$tgt/contents/ui/" 2>/dev/null || true
      cp -r "$srcDir/containments/panel/"*.js "$tgt/contents/ui/" 2>/dev/null || true
      if [ -f "$srcDir/containments/panel/metadata.json" ]; then
        cp "$srcDir/containments/panel/metadata.json" "$tgt/"
        if ! grep -q '"KPackageStructure"' "$tgt/metadata.json"; then
          sed -i '1s/^{/{\n    "KPackageStructure": "Plasma\/Containment",/' "$tgt/metadata.json"
        fi
      fi
      [ -f "$srcDir/containments/panel/main.xml" ] && {
        mkdir -p "$tgt/contents/config"
        cp "$srcDir/containments/panel/main.xml" "$tgt/contents/config/main.xml"
      }
    fi
    test -f "$tgt/metadata.json"
    find "$tgt/contents/ui" -type f -name '*.qml' -print -quit | grep -q .
  '';

  # Plasma libraries, shell, and applets must come from one release. This
  # catches accidental stable/unstable mixing before it reaches plasmashell.
  plasmaPackages = with pkgs.kdePackages; [
    plasma-desktop
    plasma-workspace
    plasma-nm
    plasma-pa
    bluedevil
    kscreen
  ];
  plasmaVersions = lib.unique (map (package: package.version) plasmaPackages);
in
{
  assertions = [
    {
      assertion = builtins.length plasmaVersions == 1;
      message = "KDE Plasma components must use one version, got: ${lib.concatStringsSep ", " plasmaVersions}";
    }
  ];

  # 用 overlay 根治上游 plasma 包漏装的 QML（关闭服务方 plasma6.enable 也生效）。
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages // {
        plasma-desktop = (prev.kdePackages.plasma-desktop).overrideAttrs (old: {
          postInstall = makeQmlInstall old plasmaDesktopApplets + panelFix;
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
    kdePackages.yakuake
    kdePackages.kdevelop
  ];
}
