/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: Qoder CN IDE —— 阿里云通义 AI 编程 IDE（Electron，deb 打包）。
 *
 * 下载 URL（从 qoder.com.cn/download 页面的 JS chunk 捕获）：
 *   https://ide.qoder.com.cn/qoder/release/lastest/qoder-cn_amd64.deb
 * 更新：改 version + hash（nix build 报错会给出真实 hash）。
 *
 * 注意：Qoder Work（agent 工作台）只有 Win/Mac 版，无 Linux 客户端。
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
  pname = "qoder-cn";
  version = "1.25.1";

  src = fetchurl {
    url = "https://ide.qoder.com.cn/qoder/release/lastest/qoder-cn_amd64.deb";
    hash = "sha256-3mEzzYVIaaOcZfDxHsYnA7FDbLLBcuPjK3wej/sZl1c=";
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
    mkdir -p $out/share/qoder-cn

    cp -r usr/share/qoder-cn/* $out/share/qoder-cn/
    cp -r usr/share/applications/*.desktop $out/share/applications/ 2>/dev/null || true
    cp -r usr/share/pixmaps/* $out/share/pixmaps/ 2>/dev/null || true

    find $out -name "chrome-sandbox" -exec chmod 0755 {} \; 2>/dev/null || true
    chmod 0755 $out/share/qoder-cn/qoder-cn

    autoPatchelf $out

    if [ -f "$out/share/qoder-cn/qoder-cn" ]; then
      cat > $out/bin/qoder-cn <<EOF
    #!/usr/bin/env bash
    export ELECTRON_FORCE_IS_PACKAGED=1
    export ELECTRON_DISABLE_SANDBOX=1
    # HiDPI：Qoder 与 Trae 同为 Electron，2560x1600@160% 下误判缩放，
    # 强制与 KDE 显示缩放一致（KDE 缩放改后同步此值）。
    exec $out/share/qoder-cn/qoder-cn --no-sandbox --force-device-scale-factor=1.0 "\$@"
    EOF
      chmod +x $out/bin/qoder-cn
    else
      echo "qoder-cn executable was not found under share/qoder-cn" >&2
      exit 1
    fi

    sed -i "s|^Exec=/usr/share/qoder-cn/qoder-cn %F|Exec=$out/bin/qoder-cn %F|" \
      $out/share/applications/qoder-cn.desktop 2>/dev/null || true
    sed -i "s|^Exec=/usr/share/qoder-cn/qoder-cn --new-window %F|Exec=$out/bin/qoder-cn --new-window %F|" \
      $out/share/applications/qoder-cn-url-handler.desktop 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "Qoder CN IDE - Alibaba Cloud AI coding IDE";
    homepage = "https://qoder.com.cn";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "qoder-cn";
  };
}
