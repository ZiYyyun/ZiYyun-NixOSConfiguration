/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: plasma-workspace / plasma-nm / plasma-pa 的 applet QML 补丁包。
 *
 * nixpkgs 26.05（rev 02e08985）的 plasma-workspace/plasma-nm/plasma-pa 构建
 * 和 plasma-desktop 一样漏装了 applet QML：share/plasma/plasmoids/<id> 里
 * 只有 metadata.json（甚至什么都没有），plasmashell 报
 * 「加载小程序出错：软件包 不存在」——digitalclock / systemtray /
 * panelspacer / notifications / clipboard / networkmanagement / volume ...
 *
 * 本包从上游源码 tarball 提取这些 applet 的 contents/ui 并按标准 KPackage
 * 布局安装，与 plasma-desktop-qml 互补（那个管 plasma-desktop 的 applets）。
 *
 * 说明：
 *  - org.kde.plasma.battery / brightness 在 Plasma 6.6 上游已不在
 *    plasma-workspace/plasma-desktop 源码（暂缺，托盘少两个图标，不影响稳定）
 *  - bluedevil 的蓝牙 applet 含 C++ 插件，需要完整构建（暂缺）
 */
{
  lib,
  stdenv,
  fetchurl,
}:

let
  workspace = fetchurl {
    name = "plasma-workspace.tar.xz";
    url = "https://download.kde.org/stable/plasma/6.6.6/plasma-workspace-6.6.6.tar.xz";
    hash = "sha256-yf/kEQtZ5GWrLV1DHbIYX+xuoQn6OeTzysBMlVPCins=";
  };
  plasmaNm = fetchurl {
    name = "plasma-nm.tar.xz";
    url = "https://download.kde.org/stable/plasma/6.6.6/plasma-nm-6.6.6.tar.xz";
    hash = "sha256-lBa/DfClIpIMK4LkPP16AJyhLp4tF5XG6NOOOABL7EA=";
  };
  plasmaPa = fetchurl {
    name = "plasma-pa.tar.xz";
    url = "https://download.kde.org/stable/plasma/6.6.6/plasma-pa-6.6.6.tar.xz";
    hash = "sha256-wW/MaKlU7WnQ/gyLCiPjBsl1EsZriF0NTcJHqgQZ/Us=";
  };
in
stdenv.mkDerivation {
  pname = "plasma-workspace-applet-qml";
  version = "6.6.6";

  src = workspace;
  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "true";

  installPhase = ''
    runHook preInstall

    mkdir -p /tmp/pw-src /tmp/pnm-src /tmp/ppa-src
    tar xJf ${workspace} -C /tmp/pw-src --strip-components=1
    tar xJf ${plasmaNm} -C /tmp/pnm-src --strip-components=1
    tar xJf ${plasmaPa} -C /tmp/ppa-src --strip-components=1

    outPlasmoids=$out/share/plasma/plasmoids

    install_applet() { # $1=plugin id  $2=源码目录
      local id="$1" dir="$2"
      local target="$outPlasmoids/$id"
      mkdir -p "$target/contents/ui"
      cp "$dir/metadata.json" "$target/"

      if [ -d "$dir/qml" ]; then
        cp -r "$dir/qml/." "$target/contents/ui/"
      else
        cp "$dir"/*.qml "$target/contents/ui/" 2>/dev/null || true
        [ -d "$dir/code" ] && cp -r "$dir/code" "$target/contents/ui/"
      fi

      if [ -f "$dir/main.xml" ]; then
        mkdir -p "$target/contents/config"
        cp "$dir/main.xml" "$target/contents/config/main.xml"
      fi

      # 上游源码里的 metadata.json 缺 KPackageStructure 字段（nixpkgs 构建时
      # 才会注入 "Plasma/Applet"），plasmashell 会因格式不匹配拒绝加载
      # （日志：does not match requested format "Plasma/Applet"）。
      if ! grep -q '"KPackageStructure"' "$target/metadata.json"; then
        sed -i '1s/^{/{\n    "KPackageStructure": "Plasma\/Applet",/' "$target/metadata.json"
      fi
    }

    # plasma-workspace applets
    install_applet org.kde.plasma.digitalclock /tmp/pw-src/applets/digital-clock
    install_applet org.kde.plasma.systemtray /tmp/pw-src/applets/systemtray
    install_applet org.kde.plasma.panelspacer /tmp/pw-src/applets/panelspacer
    install_applet org.kde.plasma.notifications /tmp/pw-src/applets/notifications
    install_applet org.kde.plasma.clipboard /tmp/pw-src/applets/clipboard
    install_applet org.kde.plasma.devicenotifier /tmp/pw-src/applets/devicenotifier
    install_applet org.kde.plasma.mediacontroller /tmp/pw-src/applets/mediacontroller
    install_applet org.kde.plasma.cameraindicator /tmp/pw-src/applets/cameraindicator

    # plasma-nm / plasma-pa applets（applet/ 根目录 QML 形式）
    install_applet org.kde.plasma.networkmanagement /tmp/pnm-src/applet
    install_applet org.kde.plasma.volume /tmp/ppa-src/applet

    runHook postInstall
  '';

  meta = with lib; {
    description = "QML applet frontends missing from nixpkgs plasma-workspace/plasma-nm/plasma-pa builds";
    homepage = "https://invent.kde.org/plasma/plasma-workspace";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
