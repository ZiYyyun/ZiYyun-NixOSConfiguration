/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: QML applet frontends missing from the nixpkgs plasma-desktop build.
 *
 * nixpkgs 26.05 (rev 02e08985) builds plasma-desktop 6.6.6 without the QML
 * frontend of most applets: share/plasma/plasmoids/<id> only contains
 * metadata.json, so plasmashell reports "加载小程序出错：软件包不存在" for
 * icontasks (whose X-Plasma-RootPath points at org.kde.plasma.taskmanager),
 * kickoff, windowlist, and so on.
 *
 * This package extracts the missing contents/ui QML files from the upstream
 * plasma-desktop tarball and installs them in the standard KPackage layout,
 * so plasmashell can load those applets again.
 */
{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "6.6.6";
in
stdenv.mkDerivation {
  pname = "plasma-desktop-applet-qml";
  inherit version;

  src = fetchurl {
    url = "https://download.kde.org/stable/plasma/${version}/plasma-desktop-${version}.tar.xz";
    sha256 = "sha256-268SrI3PihK6PqCXwR5x6Ea+SzZzfvYkIOEc83pPY44=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    srcApplets=$PWD/applets
    outPlasmoids=$out/share/plasma/plasmoids

    install_applet() {
      local id="$1" dir="$2"
      local target="$outPlasmoids/$id"
      mkdir -p "$target/contents/ui"
      cp "$dir/metadata.json" "$target/"

      # 上游 tarball 的 metadata.json 没有 KPackageStructure 字段（nixpkgs
      # 构建时会注入 "Plasma/Applet"），plasmashell 会因此拒绝加载该 applet
      # （"KPackageStructure ... does not match requested format"）。这里补上，
      # 与 nixpkgs 构建的 metadata 保持一致。
      if ! grep -q '"KPackageStructure"' "$target/metadata.json"; then
        sed -i '1s/^{/{\n    "KPackageStructure": "Plasma\/Applet",/' "$target/metadata.json"
      fi

      if [ -d "$dir/qml" ]; then
        # qml/ 子目录形式：taskmanager pager showdesktop keyboardlayout ...
        cp -r "$dir/qml/." "$target/contents/ui/"
      else
        # 根目录形式：kickoff kicker window-list trash ...
        cp "$dir"/*.qml "$target/contents/ui/" 2>/dev/null || true
        [ -d "$dir/code" ] && cp -r "$dir/code" "$target/contents/ui/"
      fi

      if [ -f "$dir/main.xml" ]; then
        mkdir -p "$target/contents/config"
        cp "$dir/main.xml" "$target/contents/config/main.xml"
      fi
    }

    install_applet org.kde.plasma.taskmanager "$srcApplets/taskmanager"
    install_applet org.kde.plasma.pager "$srcApplets/pager"
    install_applet org.kde.plasma.showdesktop "$srcApplets/showdesktop"
    install_applet org.kde.plasma.kickoff "$srcApplets/kickoff"
    install_applet org.kde.plasma.kicker "$srcApplets/kicker"
    install_applet org.kde.plasma.keyboardlayout "$srcApplets/keyboardlayout"
    install_applet org.kde.plasma.kimpanel "$srcApplets/kimpanel"
    install_applet org.kde.plasma.marginsseparator "$srcApplets/margins-separator"
    install_applet org.kde.plasma.showActivityManager "$srcApplets/showActivityManager"
    install_applet org.kde.plasma.windowlist "$srcApplets/window-list"
    install_applet org.kde.plasma.trash "$srcApplets/trash"

    runHook postInstall
  '';

  meta = with lib; {
    description = "QML applet frontends missing from the nixpkgs plasma-desktop build";
    homepage = "https://invent.kde.org/plasma/plasma-desktop";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
