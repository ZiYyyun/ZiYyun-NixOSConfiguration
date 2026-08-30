/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-30
 * Description: Qwen Studio（通义千问桌面客户端，Tauri v2）社区 Linux 版。
 *
 * 注意：阿里官方 Qwen Studio 只发布 Windows/macOS。本包封装的是社区
 * 第三方 Linux 移植（https://github.com/youssefvdel/qwen-studio），
 * Tauri v2 + WebKitGTK，约 6MB。功能与官方桌面版一致。
 *
 * 若官方以后发布 Linux 版，优先换用官方源。
 *
 * 更新：改 version + src.hash（nix build 报错会给出真实 hash）；
 * 最新 release 见 https://github.com/youssefvdel/qwen-studio/releases/latest
 */
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  webkitgtk_4_1,
  gtk3,
  glib,
  gdk-pixbuf,
  cairo,
  pango,
  atk,
  libsoup_3,
  openssl,
  libnotify,
  dbus,
  zlib,
  harfbuzz,
  fontconfig,
  freetype,
  xorg,
  libGL,
  libayatana-appindicator,
}:

stdenv.mkDerivation rec {
  pname = "qwen";
  version = "2.2.3";

  # 运行时需 dlopen 的库（Tauri 的 appindicator 不读 RPATH），必须经
  # LD_LIBRARY_PATH 提供给 wrapper。
  runtimeLibraryPath = lib.makeLibraryPath [
    libayatana-appindicator
    webkitgtk_4_1
  ];

  src = fetchurl {
    url = "https://github.com/youssefvdel/qwen-studio/releases/download/v${version}/Qwen.Studio_${version}_amd64.deb";
    hash = "sha256-ThLYNnf+jHV5nNJMsXioIkQYRkYpT6YMB1MYOSBojKI=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    glib
    gdk-pixbuf
    cairo
    pango
    atk
    libsoup_3
    openssl
    libnotify
    dbus
    zlib
    harfbuzz
    fontconfig
    freetype
    xorg.libxcb
    xorg.libX11
    xorg.libXrender
    xorg.libXi
    libGL
    # 系统托盘指示器：Tauri 用 dlopen 加载 ayatana-appindicator3（不读 RPATH），
    # 因此必须在 wrapper 里通过 LD_LIBRARY_PATH 提供。
    libayatana-appindicator
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/applications $out/share/icons

    # Tauri deb 通常把二进制放 usr/bin，资源放 usr/lib/<name>/
    if [ -f usr/bin/qwen-studio ] || [ -f usr/bin/QwenStudio ] || [ -f usr/bin/qwen ]; then
      local exe=$(ls usr/bin/* 2>/dev/null | head -1)
      mkdir -p $out/lib
      # 把二进制 + 同级资源移到 $out/lib 保持相对结构
      cp -r $(dirname "$exe")/. $out/lib/ 2>/dev/null
      # desktop / icon
      cp -r usr/share/applications/* $out/share/applications/ 2>/dev/null || true
      cp -r usr/share/icons/* $out/share/icons/ 2>/dev/null || true

      local binname=$(basename "$exe")
      # 若 deb 里还有 usr/lib/qwen-studio 等资源目录，一并拷
      if [ -d usr/lib ]; then
        cp -r usr/lib/* $out/lib/ 2>/dev/null || true
      fi

      # wrapper：用 makeWrapper 生成，注入运行时 dlopen 所需 LD_LIBRARY_PATH，
      # 并保留 WebKitGTK 需要的组合/渲染禁用变量（见 desktop 里原有 env）。
      makeWrapper "$out/lib/$binname" $out/bin/$binname \
        --prefix LD_LIBRARY_PATH : "$runtimeLibraryPath"

      # 修正 .desktop 的 Exec 指向我们的 wrapper（保留 WEBKIT 环境变量前缀）。
      sed -i "s|/usr/bin/$binname|$out/bin/$binname|g" \
        $out/share/applications/*.desktop 2>/dev/null || true
    else
      echo "qwen-studio executable not found in usr/bin" >&2
      find usr -maxdepth 3 -type f -executable 2>/dev/null | head
      exit 1
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Qwen Studio (community Linux build) - Alibaba Qwen AI desktop client";
    homepage = "https://github.com/youssefvdel/qwen-studio";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
    mainProgram = "qwen-studio";
  };
}