/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: Onlyrics — a panel plasmoid that shows the current song's
 * lyrics line by line. Vendored from
 * https://github.com/Illuminate-dev/plasmoid-onlyrics (GPL-2.0+).
 *
 * Patched for this setup:
 *  - lrclib.patch: upstream defaults to apiURL=none, so the widget always
 *    showed "No lyrics available!". Now it queries LRCLIB (https://lrclib.net)
 *    by default (exact match, then search fallback, LRC parsing) and keeps
 *    the legacy {time,words} API as an optional override.
 *  - mainxml.patch: fix malformed "<default>100<default>" tag.
 *
 * Works with any MPRIS2-capable player (netease-cloud-music-gtk,
 * YesPlayMusic, Spotify, ...).
 */
{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "plasmoid-onlyrics";
  version = "2024-01-08";

  # github.com 直连不通，走 ghfast.top 代理（与本仓库其他 input 一致）。
  # 与 codeload 原始 tarball 内容一致（同一 rev 的 GitHub archive）。
  src = fetchurl {
    url = "https://ghfast.top/https://github.com/Illuminate-dev/plasmoid-onlyrics/archive/e98548bfa516cf7fab44eb8d0fa20dd7b50b32ce.tar.gz";
    sha256 = "0jcpcxy66ycnlnxh2008k0d8knkmxb9l8c10qwmr968favvdpj5z";
  };

  dontBuild = true;
  dontConfigure = true;

  patches = [
    ./lrclib.patch
    ./mainxml.patch
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/plasma/plasmoids/com.github.illuminate-dev.onlyrics"
    cp -r package/* "$out/share/plasma/plasmoids/com.github.illuminate-dev.onlyrics/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Plasma panel widget showing the current song's lyrics (LRCLIB)";
    homepage = "https://github.com/Illuminate-dev/plasmoid-onlyrics";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
