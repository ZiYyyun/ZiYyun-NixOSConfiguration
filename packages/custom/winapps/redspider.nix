/**
 * File: redspider.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: 红蜘蛛多媒体网络教室 学生端, packaged with Wine.
 *
 * Uses the teacher-provided installer (vendor/redspider-teacher/) — the
 * 加密狗 (dongle) edition, which the school requires. The official site's
 * build has no dongle components.
 *
 * The installer is a separated InstallShield package whose silent install
 * fails inside Wine. We bypass it entirely: unshield extracts the cabs at
 * build time, program files are assembled into $out/lib, and the wrapper
 * runs REDAgent.exe (student agent) straight from the Nix store — green-run,
 * fully reproducible.
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
  version = "teacher-2021";
  src = ./vendor/redspider-teacher;
  # Extract the InstallShield cabs with unshield and assemble the app dir.
  extraNativeBuildInputs = [ pkgs.unshield ];
  preInstall = ''
    mkdir -p /build/unshield-out
    unshield -d /build/unshield-out x "$PWD/data1.cab" >/dev/null
    mkdir -p "$out/lib/redspider-student/app"
    for d in CompoClient CompoClientLibrary CompoShared CompoSystemShared \
             CompoTutor CompoRedMirror CompoNetDogCommon; do
      if [ -d "/build/unshield-out/$d" ]; then
        cp -r "/build/unshield-out/$d/." "$out/lib/redspider-student/app/"
      fi
    done
    chmod -R u+w "$out/lib/redspider-student/app"
  '';
  mode = "extract";
  mainExe = "app/REDAgent.exe";
  # 广播窗口在原生 Wayland 驱动下无法点击/拖动（Windows 下正常），
  # 强制 X11 (XWayland) 驱动修复窗口交互。
  forceX11 = true;
  desktopName = "红蜘蛛学生端";
  description = "红蜘蛛多媒体网络教室 学生端（教师版，加密狗授权）";
  categories = "Education";
}
