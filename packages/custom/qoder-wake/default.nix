/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: Qoder Wake（CN: qoderwake-cn）—— Qoder 的本地语音唤醒/智能体服务。
 *
 * 官方分发渠道（download.qoder.com 的 manifest.json / install.sh）：
 *   qoderwake:  https://download.qoder.com/qoderwake/releases/<v>/qoderwake_<v>_linux_amd64.tar.gz
 *   qodercli:   https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/<v>/qodercli-linux-x64.tar.gz
 *
 * 二进制与 resources/ 必须同级（程序按相对路径加载资源），因此本体放
 * $out/lib/qoderwake/，bin 下只放 wrapper。运行时数据默认 ~/.qoderwake。
 * 更新：改版本 + 两个 hash（nix build 报错会给出真实值）。
 */
{ lib, stdenv, fetchurl, makeWrapper, autoPatchelfHook }:


stdenv.mkDerivation rec {
  pname = "qoder-wake";
  version = "0.3.5"; # qodercli 1.1.8

  src = fetchurl {
    url = "https://download.qoder.com/qoderwake/releases/${version}/qoderwake_${version}_linux_amd64.tar.gz";
    hash = "sha256-hesutELSH6HzV+CbdX7VyVLGTEurFcopyNoNwUBPITo=";
  };

  srcCli = fetchurl {
    url = "https://qoder-ide.oss-accelerate.aliyuncs.com/qodercli/releases/1.1.8/qodercli-linux-x64.tar.gz";
    hash = "sha256-jQ2vaIgPHwId5oxbR5Cbq7acrja4G7cTgMN9l7DfIZk=";
  };

  dontBuild = true;
  dontConfigure = true;
  nativeBuildInputs = [ makeWrapper autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    libDir="$out/lib/qoderwake"
    mkdir -p "$libDir/qodercli" "$out/bin"

    mkdir -p /tmp/qoderwake-src
    tar xzf ${src} -C /tmp/qoderwake-src
    cp /tmp/qoderwake-src/qoderwake "$libDir/"
    cp -r /tmp/qoderwake-src/resources "$libDir/"
    mkdir -p /tmp/qodercli-src
    tar xzf ${srcCli} -C /tmp/qodercli-src
    cp /tmp/qodercli-src/qodercli "$libDir/qodercli/qodercli-wake"

    chmod 0755 "$libDir/qoderwake" "$libDir/qodercli/qodercli-wake"

    autoPatchelf "$out"

    makeWrapper "$libDir/qoderwake" "$out/bin/qoderwake"
    makeWrapper "$libDir/qodercli/qodercli-wake" "$out/bin/qodercli-wake"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Qoder Wake - local voice wake-up / agent service for Qoder";
    homepage = "https://qoder.com";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "qoderwake";
  };
}
