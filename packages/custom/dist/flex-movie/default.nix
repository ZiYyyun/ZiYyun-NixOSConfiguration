/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-31
 * Description: Flex Movie（跨平台媒体播放客户端，Tauri，deb 打包）
 *   官网下载：https://flex.movie/zh/downloads
 *   官方 CDN 直链：https://flex-download.pages.dev/updates/flex-movie_<ver>_amd64.deb
 *
 *   Depends（deb 元数据）：libayatana-appindicator3-1、libappindicator3-1、
 *   libwebkit2gtk-4.1-0、libgtk-3-0（全为 Tauri 标准依赖）。
 *
 * 更新：改 version + src.hash（nix build 报错会给出真实 hash）。
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
  gnutls,
  libnotify,
  dbus,
  zlib,
  harfbuzz,
  fontconfig,
  freetype,
  libxcb,
  libx11,
  libxrender,
  libxi,
  libGL,
  # 系统托盘：Tauri dlopen 加载，必须走 LD_LIBRARY_PATH。
  libayatana-appindicator,
  # WebKitGTK 的 TLS 后端（缺了白屏报 "TLS support is not available"）。
  glib-networking,
  # WebKitGTK 媒体播放依赖 GStreamer 插件（appsink/autoaudiosink 在 base，
  # 常见解码在 good，更多编解码在 libav）。
  gst_all_1,
}:

stdenv.mkDerivation rec {
  pname = "flex-movie";
  version = "1.4.22";

  # 运行时需 dlopen 的库（Tauri 的 appindicator 不读 RPATH），经 LD_LIBRARY_PATH 提供。
  runtimeLibraryPath = lib.makeLibraryPath [
    libayatana-appindicator
    webkitgtk_4_1
    # GStreamer 核心库：WebKit 加载 .so 插件时要解析其 DT_NEEDED 依赖
    #（libgstreamer-1.0 / libgstbase），缺了插件 dlopen 失败、元素变 NULL。
    gst_all_1.gstreamer
  ];

  # WebKitGTK 的 TLS 后端（glib-networking 提供 libgiognutls.so，经 GIO_EXTRA_MODULES 加载）。
  gioModulesDir = "${glib-networking}/lib/gio/modules";

  # GStreamer 插件搜索路径。注意：GST_PLUGIN_SYSTEM_PATH 会覆盖默认搜索路径，
  # 必须把 gstreamer 核心插件目录（fakesink/tee/queue 等 coreelements）也加进来，
  # 否则 WebKit 建媒体管线时找不到这些核心元素。gstreamer 默认 output 是 bin，
  # 而核心插件在 out output，要显式取 .out。
  gstPluginsPath = lib.makeSearchPath "lib/gstreamer-1.0" [
    gst_all_1.gstreamer.out
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
  ];

  src = fetchurl {
    url = "https://flex-download.pages.dev/updates/flex-movie_${version}_amd64.deb";
    hash = "sha256-OuPdbz3yIpEziJetwqFX563kt2bH8ou7BBAhFBNJQD4=";
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
    gnutls
    libnotify
    dbus
    zlib
    harfbuzz
    fontconfig
    freetype
    libxcb
    libx11
    libxrender
    libxi
    libGL
    libayatana-appindicator
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/applications $out/share/icons

    local exe=usr/bin/flex-movie
    if [ ! -f "$exe" ]; then
      echo "flex-movie executable not found in usr/bin" >&2
      find usr -maxdepth 3 -type f -executable 2>/dev/null | head
      exit 1
    fi

    # 真二进制放到隐藏路径，wrapper 放在 $out/bin/flex-movie（同名 -> 桌面 Exec 无需改）。
    cp "$exe" $out/bin/.flex-movie-real
    cp -r usr/share/applications/* $out/share/applications/ 2>/dev/null || true
    cp -r usr/share/icons/* $out/share/icons/ 2>/dev/null || true

    chmod -R u+w $out

    # 修补真二进制的 ELF 依赖（webkitgtk/gtk 等运行时库会用到）。
    autoPatchelf "$out"

    # 生成 wrapper：注入 dlopen 所需 LD_LIBRARY_PATH，并设 GIO_EXTRA_MODULES
    # 让 WebKitGTK 找到 TLS 后端（否则白屏/TLS 不可用）。
    makeWrapper "$out/bin/.flex-movie-real" $out/bin/flex-movie \
      --prefix LD_LIBRARY_PATH : "$runtimeLibraryPath" \
      --set GIO_EXTRA_MODULES "$gioModulesDir" \
      --set GST_PLUGIN_SYSTEM_PATH "$gstPluginsPath"
    runHook postInstall
  '';
}