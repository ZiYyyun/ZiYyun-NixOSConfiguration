/**
* File: default.nix
* Author: ziyun
* Date: 2026-07-30
* Description: Local package definition for the Trae AI IDE.
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
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "trae";
  version = "2.3.18716";

  # Packaging recipe adapted from the Trae Chinese community NixOS thread.
  src = fetchurl {
    url = "https://lf-cdn.trae.com.cn/obj/trae-com-cn/pkg/app/releases/stable/${version}/linux/Trae%20CN-linux-x64.deb";
    hash = "sha256-a2BkX4aPTuTrrW1Whoouui0NjoobnAD8V5NY/aBh5vE=";
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
    xorg.libxcb
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXcursor
    xorg.libxkbfile
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  unpackPhase = ''
    runHook preUnpack
    # dpkg-deb -x 会尝试设置 chrome-sandbox 的 setuid 位，Nix 沙箱不允许；
    # 改用 tar 流解压并忽略原权限（installPhase 里再统一 chmod）。
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
    runHook postUnpack
  '';

  installPhase = ''
  runHook preInstall

  mkdir -p $out/bin
  mkdir -p $out/share/applications
  mkdir -p $out/share/pixmaps
  mkdir -p $out/share/trae
  mkdir -p $out/lib

  cp -r usr/bin/* $out/bin/ 2>/dev/null || true
  cp -r usr/share/applications/* $out/share/applications/ 2>/dev/null || true
  cp -r usr/share/pixmaps/* $out/share/pixmaps/ 2>/dev/null || true
  cp -r usr/share/icons/* $out/share/pixmaps/ 2>/dev/null || true
  cp -r usr/share/trae-cn/* $out/share/trae/ 2>/dev/null || true
  cp -r usr/lib/* $out/lib/ 2>/dev/null || true
  cp -r opt $out/ 2>/dev/null || true

  find $out -name "chrome-sandbox" -exec chmod 0755 {} \; 2>/dev/null || true
  find $out -name "trae-cn" -type f -exec chmod 0755 {} \; 2>/dev/null || true

  autoPatchelf $out

  if [ -f "$out/share/trae/bin/trae-cn" ]; then
  cat > $out/bin/trae <<EOF
  #!/usr/bin/env bash
  export ELECTRON_FORCE_IS_PACKAGED=1
  export ELECTRON_DISABLE_SANDBOX=1
  export DISABLE_GPU_SANDBOX=1
  exec $out/share/trae/bin/trae-cn --no-sandbox "\$@"
  EOF
  chmod +x $out/bin/trae
  else
  echo "Trae executable was not found under usr/share/trae-cn/bin/trae-cn" >&2
  exit 1
  fi

  if [ -f "$out/share/applications/trae-cn.desktop" ]; then
  sed -i "s|Exec=.*|Exec=$out/bin/trae|g" $out/share/applications/trae-cn.desktop
  mv $out/share/applications/trae-cn.desktop $out/share/applications/trae.desktop
  fi

  runHook postInstall
  '';

  meta = {
    description = "Trae IDE - AI-powered development environment";
    homepage = "https://www.trae.com.cn";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "trae";
  };
}
