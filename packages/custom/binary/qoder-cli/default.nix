/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: Qoder CN CLI（qoderclicn）—— 终端 AI 编程助手（qoder.com.cn）。
 *
 * 官方安装器（curl -fsSL https://qoder.com.cn/install | bash）会拉取
 * static.qoder.com.cn 的 manifest 找 linux/amd64 包；本包直接 fetch 对应
 * tarball。tarball 内只有一个 Bun 编译的单文件 ELF（qoderclicn），仅动态
 * 链接 glibc，用 autoPatchelfHook 改解释器即可在 NixOS 运行。
 *
 * 用法：qodercli / qoderclicn（交互式 TUI），qodercli -p "..."（非交互）。
 * 登录：qodercli login（浏览器）或 QODER_PERSONAL_ACCESS_TOKEN / 
 * QODERCN_DEVICE_TOKEN 环境变量。
 *
 * 更新：改 version + src.hash（nix build 报错会给出真实值；版本见
 * https://static.qoder.com.cn/qoder-cli-cn/channels/manifest.json）。
 */
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "qoder-cli-cn";
  version = "1.1.29";

  src = fetchurl {
    url = "https://static.qoder.com.cn/qoder-cli-cn/releases/${version}/qoderclicn-linux-x64.tar.gz";
    hash = "sha256-gS9Ze2AYXT/My1oy6HepipzjdiOZNZc3kgjpf46pH+I=";
  };

  dontBuild = true;
  dontConfigure = true;
  # Bun 编译的单文件二进制：stripPhase 会破坏内嵌应用数据，必须跳过
  # （与 qoder-wake 同理）。
  dontStrip = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/qodercli" "$out/bin"

    # 解包单文件二进制（tarball 内只有 qoderclicn）。
    tar xzf ${src} -C "$out/lib/qodercli" --strip-components=1
    chmod 0755 "$out/lib/qodercli/qoderclicn"

    # 动态链接 glibc（解释器 /lib64/ld-linux-x86-64.so.2），改解释器使其
    # 在 NixOS 可运行。
    autoPatchelf "$out"

    # 命令名：二进制本体 qoderclicn；官方文档/NPM 入口是 qodercli，两个都提供。
    ln -s "$out/lib/qodercli/qoderclicn" "$out/bin/qodercli"
    ln -s qodercli "$out/bin/qoderclicn"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Qoder CLI CN - terminal AI coding assistant (qoder.com.cn)";
    homepage = "https://qoder.com.cn";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "qodercli";
  };
}
