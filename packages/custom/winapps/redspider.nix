/**
 * File: redspider.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: 红蜘蛛多媒体网络教室 (Red Spider) packaged with Wine.
 *
 * Installer is fetched automatically from the official site
 * (www.3000soft.net, pinned hash) — no manual download needed. The package
 * is an InstallShield installer; the wrapper silently installs it using the
 * bundled response file usetup.iss:
 *   setup.exe /s /f1"<usetup.iss>" /f2"<log>"
 *
 * Usage:
 *   nix run .#redspider-student
 */
{ pkgs, callPackage }:
let
  mkWineApp = callPackage ./wine-app.nix { };
in
mkWineApp {
  pname = "redspider-student";
  version = "7.2.1785";
  src = pkgs.fetchurl {
    url = "http://www.3000soft.net/cmain/download/red_spider_v721785.zip";
    sha256 = "sha256-+Dk8lkSI7tr0xdBqt1GusuhZrQ19fd46XicYLE1kdbs=";
  };
  mode = "firstrun-install";
  # The official zip has no top-level directory, so unpack manually.
  unpackPhase = ''
    mkdir -p src && cd src
    unzip "$src" >/dev/null
  '';
  # InstallShield silent install: the response file must be addressed as a
  # Windows path (C:\usetup.iss), otherwise setup fails with ResultCode=-3.
  installCmd = ''
    cp "$APP_DIR/usetup.iss" "$WINEPREFIX/drive_c/usetup.iss"
    wine "$APP_DIR/setup.exe" /s /f1"C:\usetup.iss" /f2"$(winepath -w "$WINEPREFIX/redspider-install.log")" >/dev/null 2>&1 || true
  '';
  # Student agent is installed under Program Files/3000soft.
  exeSearchDir = "Program Files/3000soft";
  desktopName = "红蜘蛛学生端";
  description = "红蜘蛛多媒体网络教室 学生端（Windows/Wine）";
  categories = "Education";
}
