/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: bluedevil 蓝牙托盘 applet 的 QML 前端补丁包。
 *
 * nixpkgs 26.05（rev 02e08985）构建 bluedevil 6.6.6 时漏装了
 * share/plasma/plasmoids/org.kde.plasma.bluetooth 的 QML 前端（与
 * plasma-desktop/workspace 同病），导致系统托盘里蓝牙图标不出现。
 *
 * 本包从 bluedevil 上游 tarball 提取该 applet 的 QML 前端安装到标准
 * KPackage 布局。C++ 部分（org.kde.plasma.bluetooth.so 插件 +
 * org.kde.plasma.private.bluetooth QML 模块）nixpkgs 已构建好，无需重编。
 */
{ lib, stdenv, fetchurl }:

let
  version = "6.6.6";
in
stdenv.mkDerivation {
  pname = "bluedevil-applet-qml";
  inherit version;

  src = fetchurl {
    url = "https://download.kde.org/stable/plasma/${version}/bluedevil-${version}.tar.xz";
    hash = "sha256-r6dJIgaINwY1C4U/Hb/osslPjDpJ5twUfNXLlhShLHM=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    # 默认 unpackPhase 已进入解包后的 bluedevil-6.6.6/（sourceRoot）。
    local target="$out/share/plasma/plasmoids/org.kde.plasma.bluetooth"
    mkdir -p "$target/contents/ui" "$target/contents/config"
    cp "$PWD/src/applet/metadata.json" "$target/"
    cp "$PWD/src/applet/main.xml" "$target/contents/config/"
    cp "$PWD/src/applet/qml/"*.qml "$target/contents/ui/"

    # 上游 tarball 的 metadata.json 缺 KPackageStructure 字段（nixpkgs 构建
    # 时才会注入 "Plasma/Applet"），plasmashell 会因格式不匹配拒绝加载。
    if ! grep -q '"KPackageStructure"' "$target/metadata.json"; then
      sed -i '1s/^{/{\n    "KPackageStructure": "Plasma\/Applet",/' "$target/metadata.json"
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bluetooth system tray applet QML frontend missing from nixpkgs bluedevil build";
    homepage = "https://invent.kde.org/plasma/bluedevil";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
