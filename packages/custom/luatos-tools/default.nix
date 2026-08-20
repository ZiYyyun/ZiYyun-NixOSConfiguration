/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: 合宙 (OpenLuat) 烧录与脚本工具。
 *
 * - luatool        : kicer/luatool — Python 脚本，向 LuatOS 固件加载 init.lua/main.lua
 * - luatos-utils   : cjacker/luatos-utils — Linux 下生成/烧录 script.img
 *                    （Air101/Air103/ESP32S3/ESP32C3），含 mkscriptbin 工具
 */
{ lib, pkgs, fetchFromGitHub, python3 }:

let
  pythonEnv = python3.withPackages (ps: [ ps.pyserial ]);

  luatool = pkgs.stdenv.mkDerivation {
    pname = "luatool";
    version = "unstable-2023";
    src = fetchFromGitHub {
      owner = "kicer";
      repo = "luatool";
      rev = "master";
      sha256 = "sha256-hxdLzJrZXgTdXST9JPAF+PlUlx0/ZHsL/9TDk2a9Mwg=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin $out/lib/luatool
      cp -r luatool $out/lib/
      cat > $out/bin/luatool <<EOF
      #!/usr/bin/env bash
      exec ${pythonEnv}/bin/python3 $out/lib/luatool/luatool.py "\$@"
      EOF
      chmod +x $out/bin/luatool
    '';
  };

  luatosUtils = pkgs.stdenv.mkDerivation {
    pname = "luatos-utils";
    version = "unstable-2023";
    src = fetchFromGitHub {
      owner = "cjacker";
      repo = "luatos-utils";
      rev = "main";
      sha256 = "sha256-eJCLEUgU2hkQDTigdM7pmHYErpof6wUvZSp83sNPOlI=";
    };
    nativeBuildInputs = [ pkgs.gcc ];
    buildPhase = ''
      gcc -O2 -o mkscriptbin utils/mkscriptbin.c
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp mkscriptbin $out/bin/
    '';
  };
in
{
  inherit luatool luatosUtils;
}
