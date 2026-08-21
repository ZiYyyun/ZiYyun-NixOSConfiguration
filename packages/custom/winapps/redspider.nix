/**
 * File: redspider.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: 红蜘蛛多媒体网络教室 学生端, packaged with Wine.
 *
 * The official installer is a separated InstallShield package whose silent
 * install fails inside Wine (ResultCode=-3, InstallSource/Temp issues).
 * Instead we bypass the installer entirely: unshield extracts data1.cab at
 * build time, the program files are assembled into $out/lib, and the wrapper
 * runs REDAgent.exe (student agent) straight from the Nix store — green-run,
 * fully reproducible, no installer involved.
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
  # The official zip has no top-level directory, so unpack manually.
  unpackPhase = ''
    mkdir -p src && cd src
    unzip "$src" >/dev/null
  '';
  # Extract the InstallShield data with unshield and assemble the app dir
  # (student agent + client libraries + shared components).
  extraNativeBuildInputs = [ pkgs.unshield ];
  preInstall = ''
    mkdir -p /build/unshield-out
    unshield -d /build/unshield-out x "$PWD/data1.cab" >/dev/null
    mkdir -p "$out/lib/redspider-student/app"
    for d in CompoClient CompoClientLibrary CompoShared CompoSystemShared CompoTutor; do
      if [ -d "/build/unshield-out/$d" ]; then
        cp -r "/build/unshield-out/$d/." "$out/lib/redspider-student/app/"
      fi
    done
    chmod -R u+w "$out/lib/redspider-student/app"
  '';
  mode = "extract";
  mainExe = "app/REDAgent.exe";
  desktopName = "红蜘蛛学生端";
  description = "红蜘蛛多媒体网络教室 学生端（Windows/Wine，绿色解包）";
  categories = "Education";
}
