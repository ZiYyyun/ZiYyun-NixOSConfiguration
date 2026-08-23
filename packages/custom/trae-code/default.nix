/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: Local package definition for TraeCode — TRAE 的新版 AI IDE（GUI）。
 *
 * 这是 TRAE 大版本迭代后的 IDE（官网首页「下载 TraeCode」按钮指向它），
 * 与旧版 trae 包（2.3.18716，仍保留）并存；旧版包按用户要求冻结不再改动。
 *
 * 下载 URL 模式（从官网下载按钮捕获，版本号随发布更新）：
 *   https://lf-cdn.trae.com.cn/obj/trae-com-cn/pkg/app/releases/stable/<version>/linux/TraeCode_CN-linux-x64.deb
 *
 * 更新：改 version + hash（nix build 报错会给出真实 hash）。
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
  pname = "trae-code";
  version = "2.3.73737";

  src = fetchurl {
    url = "https://lf-cdn.trae.com.cn/obj/trae-com-cn/pkg/app/releases/stable/${version}/linux/TraeCode_CN-linux-x64.deb";
    hash = "sha256-k2l3NlZZSZDkKhzmjF/SINmdWFGVwAw2gSjwdc7aSTA=";
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
    mkdir -p $out/share/trae-code

    cp -r usr/share/trae-cn/* $out/share/trae-code/
    cp -r usr/share/applications/* $out/share/applications/ 2>/dev/null || true
    cp -r usr/share/pixmaps/* $out/share/pixmaps/ 2>/dev/null || true

    find $out -name "chrome-sandbox" -exec chmod 0755 {} \; 2>/dev/null || true
    chmod 0755 $out/share/trae-code/trae-cn

    autoPatchelf $out

    if [ -f "$out/share/trae-code/trae-cn" ]; then
      cat > $out/bin/trae-code <<EOF
    #!/usr/bin/env bash
    export ELECTRON_FORCE_IS_PACKAGED=1
    export ELECTRON_DISABLE_SANDBOX=1
    export DISABLE_GPU_SANDBOX=1
    # HiDPI 修正：Electron 在 2560x1600@160% 缩放下常误判为 2.0 导致 UI 过大；
    # 强制与 KDE 显示缩放一致（KDE 缩放改后同步此值，或 Trae 内 Ctrl+- 微调）。
    exec $out/share/trae-code/trae-cn --no-sandbox --force-device-scale-factor=1.0 "\$@"
    EOF
      chmod +x $out/bin/trae-code
    else
      echo "TraeCode executable was not found under share/trae-code/trae-cn" >&2
      exit 1
    fi

    if [ -f "$out/share/applications/trae-cn.desktop" ]; then
      # 精确替换：Action 内的 --new-window 行与主 Exec 行分别处理，避免互相覆盖。
      sed -i "s|^Exec=/usr/share/trae-cn/trae-cn --new-window %F|Exec=$out/bin/trae-code --new-window %F|" $out/share/applications/trae-cn.desktop
      sed -i "s|^Exec=/usr/share/trae-cn/trae-cn %F|Exec=$out/bin/trae-code %F|" $out/share/applications/trae-cn.desktop
      mv $out/share/applications/trae-cn.desktop $out/share/applications/trae-code.desktop
    fi

    runHook postInstall
  '';

  meta = {
    description = "TraeCode - TRAE AI IDE (new major version)";
    homepage = "https://www.trae.cn";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "trae-code";
  };
}
