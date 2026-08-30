/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-30
 * Description: CodeBuddy IDE（腾讯 AI 编程 IDE，Electron，deb 打包）。
 *
 * 官网：https://www.codebuddy.cn/ide/
 * 官方 Linux x86_64 deb 直链（腾讯官方 CDN）：
 *   https://download.codebuddy.cn/aiide/linux-x64/CodeBuddy-linux-x64-<ver>.<build>-<hash>-cn.deb
 *
 * 更新：改 version/build/hash + src.hash（nix build 报错会给出真实 hash；
 * 版本信息可从 https://github.com/JipZeonGit/codebuddy-ide-cn-linux 的
 * Makefile 顶部 CB_VERSION/CB_BUILD/CB_HASH 获取）。
 */
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libappindicator-gtk3,
  libdrm,
  libgcrypt,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libsoup_3,
  libxkbcommon,
  libxshmfence,
  mesa,
  nspr,
  nss,
  pango,
  udev,
  wayland,
  webkitgtk_4_1,
  libxcb,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxscrnsaver,
  libxcursor,
  libxkbfile,
}:

stdenv.mkDerivation rec {
  pname = "codebuddy";
  version = "4.11.2";

  src = fetchurl {
    url = "https://download.codebuddy.cn/aiide/linux-x64/CodeBuddy-linux-x64-4.11.2.36529961-74e2511a-cn.deb";
    hash = "sha256-Mnh9dY9L6E5/opps7S16M213/Gif9Ta/pmSympLBSos=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libappindicator-gtk3
    libdrm
    libgcrypt
    libglvnd
    libnotify
    libpulseaudio
    libsecret
    libsoup_3
    libxkbcommon
    libxshmfence
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    udev
    wayland
    webkitgtk_4_1
    libxcb
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxscrnsaver
    libxcursor
    libxkbfile
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/pixmaps
    cp -r usr/share/* $out/share/ 2>/dev/null || true

    # CodeBuddy Electron 完整包在 share/buddycn/，主程序同级 buddycn 可执行。
    local appDir="$out/share/buddycn"
    local mainbin="$appDir/buddycn"

    # chrome-sandbox setuid 处理（Nix 不允许 setuid，强改 0755 并加 --no-sandbox）。
    find $out -name "chrome-sandbox" -exec chmod 0755 {} \; 2>/dev/null || true

    autoPatchelf $out

    # 生成启动 wrapper（--no-sandbox 避免依赖 chrome-sandbox setuid）。
    # 注意：不强制 --force-device-scale-factor，让 Electron 跟随系统 DPI 缩放
    #（此前强制 1.0 在高分屏 2560x1600 下字太小）。
    cat > $out/bin/codebuddy <<EOF
    #!/usr/bin/env bash
    export ELECTRON_FORCE_IS_PACKAGED=1
    export ELECTRON_DISABLE_SANDBOX=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    exec "$mainbin" --no-sandbox "\$@"
    EOF
    chmod +x $out/bin/codebuddy

    # 修正 .desktop 的 Exec 指向我们的 wrapper（用双引号让 $out 展开）。
    sed -i "s|^Exec=/usr/share/buddycn/bin/buddycn|Exec=$out/bin/codebuddy|g" \
      $out/share/applications/*.desktop 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "CodeBuddy IDE - Tencent AI-powered full-stack IDE";
    homepage = "https://www.codebuddy.cn/ide/";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "codebuddy";
  };
}