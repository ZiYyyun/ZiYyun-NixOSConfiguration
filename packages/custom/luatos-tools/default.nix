/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-24
 * Description: 合宙 (OpenLuat) 烧录与脚本工具。
 *
 * - luatool        : kicer/luatool — Python 脚本，向 LuatOS 固件加载 init.lua/main.lua
 *                    （注意：仅 ESP8266/NodeMCU 协议，Cat.1 如 Air780EPM 不适用）
 * - luatos-utils   : cjacker/luatos-utils — Linux 下生成/烧录 script.img
 *                    （Air101/Air103/ESP32S3/ESP32C3），含 mkscriptbin 工具
 * - luatos-cli     : openLuat/luatos-cli — 纯 Rust 命令行工具，支持多芯片刷机
 *                    （Air780EPM/EC718、Air8101/BK7258、Air101/103 等），
 *                    Cat.1 模组（如 Air780EPM）必须用它而非 luatool
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
  # 合宙官方纯 Rust CLI：Air780EPM(EC718)/Air8101/Air101 等多芯片刷机、日志、
  # 项目/固件构建。Cat.1 模组（Air780EPM 等）必须用它刷机。
  luatosCli = pkgs.rustPlatform.buildRustPackage {
    pname = "luatos-cli";
    version = "unstable-2026-08-24";
    src = pkgs.fetchgit {
      url = "https://gitee.com/openLuat/luatos-cli.git";
      rev = "55fa339cc61c94968de5f33d6c12cb0b13f19cdd";
      hash = "sha256-PYURrZA0Xp8L25wPBZun7RbRmcvXVKt2dxVSYhArUT4=";
    };
    # serialport 依赖 libudev；cargoHash 由首次构建报错给出。
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.udev ];
    cargoHash = "sha256-APiPBzzC0zBGJnpWN0Q+jiXCxOyTd19hwC+RApBJ84M=";
    # 仓库自带 .cargo/config.toml 把 crates-io 换成 ustc 镜像，会覆盖 nixpkgs 的
    # vendored-sources，导致 --offline 构建找不到 crate（报 "no matching package"）。
    postPatch = ''
      rm -f .cargo/config.toml
    '';
    # 部分测试需要串口/网络设备，构建环境跑不了，跳过。
    doCheck = false;
    meta = with lib; {
      description = "LuatOS CLI - multi-chip flashing/log/project tool (Air780EPM etc.)";
      homepage = "https://gitee.com/openLuat/luatos-cli";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
in
{
  inherit luatool luatosUtils luatosCli;
}
