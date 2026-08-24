/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: kscreen 屏幕托盘 applet（org.kde.kscreen）的 QML 前端补丁包。
 *
 * nixpkgs 26.05 构建 kscreen 6.6.6 时同样漏装了
 * share/plasma/plasmoids/org.kde.kscreen 的 QML 前端（只有 C++ 插件
 * org.kde.kscreen.so），导致系统托盘里屏幕/显示设置图标不出现。
 *
 * 本包从 kscreen 上游 tarball 提取 plasmoid 的 QML 前端安装到标准 KPackage
 * 布局，与已有的 C++ 插件配合即可加载。
 */
{ lib, stdenv, fetchurl }:

let
  version = "6.6.6";
in
stdenv.mkDerivation {
  pname = "kscreen-applet-qml";
  inherit version;

  src = fetchurl {
    url = "https://download.kde.org/stable/plasma/${version}/kscreen-${version}.tar.xz";
    hash = "sha256-e3/AhVlRqIjCdm+KE4TMeTqdpGNGKXVhqPdjgkHGLKw=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    # 默认 unpackPhase 已进入解包后的 kscreen-6.6.6/（sourceRoot）。
    local target="$out/share/plasma/plasmoids/org.kde.kscreen"
    mkdir -p "$target/contents/ui"
    cp "$PWD/plasmoid/metadata.json" "$target/"
    cp "$PWD/plasmoid/"*.qml "$target/contents/ui/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Screen/display system tray applet QML frontend missing from nixpkgs kscreen build";
    homepage = "https://invent.kde.org/plasma/kscreen";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
