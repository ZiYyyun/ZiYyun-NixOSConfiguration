/**
 * File: wine-app.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: Reusable template for packaging a Windows application with Wine.
 *
 * Two modes:
 *   - "extract": unpack the source and run the main exe directly (green
 *     software like FeiQ). No installation step.
 *   - "firstrun-install": the installer ships in the store; the wrapper runs
 *     it once into the user's WINEPREFIX on first launch. Use `installCmd`
 *     for installers with special silent flags (e.g. InstallShield response
 *     files), or `installer`+`installerArgs` for plain NSIS-style /S.
 *
 * CJK fonts: on first launch the wrapper copies wqy-zenhei into the Wine
 * prefix and registers SimSun substitutes, so Chinese apps render correctly
 * regardless of the host fontconfig.
 *
 * The wrapper is fully reproducible: software bits come from the Nix store,
 * the WINEPREFIX is created deterministically under
 * ~/.local/share/winapps/<pname> (user data survives rebuilds).
 */
{
  lib,
  pkgs,
  stdenv,
  ...
}:
{
  pname,
  version,
  src,                       # fetchurl/fetchzip result or local path
  mode ? "extract",          # "extract" | "firstrun-install"
  mainExe ? null,            # extract mode: main exe relative to $out/lib/<pname>
  installer ? null,          # firstrun-install mode: installer file name in src
  installerArgs ? "/S",      # firstrun-install mode: silent args (NSIS style)
  installCmd ? null,         # firstrun-install mode: full install command template
                             # ($APP_DIR / $WINEPREFIX available, e.g. for
                             #  InstallShield response files)
  preInstall ? "",           # extra shell after files are copied to $out/lib/<pname>
  unpackPhase ? null,        # custom unpack (needed when the archive has no top dir)
  extraNativeBuildInputs ? [ ],  # extra build tools (e.g. unshield)
  exeSearchDir ? "Program Files",  # firstrun-install: dir under drive_c to find the app exe
  desktopName ? pname,
  description ? "",
  categories ? "Network;",
  winePkg ? pkgs.wineWowPackages.wayland,
  cjkFont ? pkgs.wqy_zenhei,
  forceX11 ? false,          # force the X11 driver (XWayland): fixes window
                             # interaction for apps whose windows misbehave
                             # under the native Wayland driver (e.g. Red Spider
                             # broadcast window cannot be clicked/dragged)
}:

assert mode == "extract" -> mainExe != null;
assert mode == "firstrun-install" -> (installer != null || installCmd != null);

let
  fontFile = "${cjkFont}/share/fonts/wqy-zenhei.ttc";

  # CJK font injection: runs on every launch until the marker exists, so it
  # also repairs prefixes created before this feature.
  fontInitBlock = ''
    if [ ! -f "$WINEPREFIX/.cjk-fonts-installed" ]; then
      wineboot -u >/dev/null 2>&1 || true
      FONTS_DIR="$WINEPREFIX/drive_c/windows/Fonts"
      mkdir -p "$FONTS_DIR"
      cp "${fontFile}" "$FONTS_DIR/wqy-zenhei.ttc"
      wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" /v "WenQuanYi Zen Hei (TrueType)" /d "wqy-zenhei.ttc" /f >/dev/null 2>&1 || true
      # Map every common CJK font name to WenQuanYi so GBK-era apps (FeiQ,
      # Red Spider) render Chinese even when they request 宋体/黑体/雅黑 etc.
      for SUB in SimSun NSimSun SimSun-ExtB SimSun-18030 "MS Song" "宋体" "新宋体" "宋体-18030" SimHei "黑体" "Microsoft YaHei" "微软雅黑" "Microsoft YaHei UI" KaiTi "楷体" "楷体_GB2312" FangSong "仿宋" "仿宋_GB2312" PMingLiU MingLiU DFKai-SB "MingLiU_HKSCS" "SimSun-PUA" DengXian "等线" "MS Shell Dlg" "MS Shell Dlg 2"; do
        wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\FontSubstitutes" /v "$SUB" /d "WenQuanYi Zen Hei" /f >/dev/null 2>&1 || true
      done
      touch "$WINEPREFIX/.cjk-fonts-installed"
    fi
  '';

  installCommand = if installCmd != null then installCmd else ''
    wine "$APP_DIR/${installer}" ${installerArgs} >/dev/null 2>&1 || true
  '';

  installBlock = if mode == "firstrun-install" then ''
    if [ ! -f "$WINEPREFIX/.${pname}-installed" ]; then
      echo "Installing ${pname} into $WINEPREFIX ..."
      ${fontInitBlock}
      ${installCommand}
      sleep 3
      touch "$WINEPREFIX/.${pname}-installed"
    fi
    SEARCH_DIR="$WINEPREFIX/drive_c/${exeSearchDir}"
    EXE=$(find "$SEARCH_DIR" -iname '*.exe' -not -iname 'unins*' 2>/dev/null | head -1)
    if [ -z "$EXE" ]; then
      echo "error: ${pname} does not seem to be installed in $WINEPREFIX" >&2
      exit 1
    fi
    cd "$(dirname "$EXE")"
    exec wine "$(basename "$EXE")" "$@"
  '' else ''
    cd "$APP_DIR"
    exec wine "${mainExe}" "$@"
  '';
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ pkgs.unzip ] ++ extraNativeBuildInputs;
  unpackPhase = if unpackPhase != null then unpackPhase else null;

  buildPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname} $out/bin $out/share/applications

    # Copy unpacked source (zip archives are unpacked by default unpackPhase;
    # single exe files land in $PWD as-is).
    if [ -f "$PWD/$(basename $src)" ] && ! [ -d "$PWD/$(basename $src)" ]; then
      cp "$PWD/$(basename $src)" $out/lib/${pname}/
    else
      cp -rT "$PWD" $out/lib/${pname}/ 2>/dev/null || true
    fi
    ${preInstall}

    # Launcher wrapper.
    cat > $out/bin/${pname} <<'WRAPPER'
    #!/usr/bin/env bash
    set -e
    export WINEPREFIX="''${WINEPREFIX:-$HOME/.local/share/winapps/${pname}}"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree,mshtml=d"
    export WINEFSYNC=1
    export WINEDEBUG=-all
    mkdir -p "$WINEPREFIX"
    ${lib.optionalString forceX11 ''
      # Force the X11 (XWayland) display driver for this prefix.
      wine reg add "HKCU\\Software\\Wine\\Drivers" /v Graphics /d "x11" /f >/dev/null 2>&1 || true
      wineserver -w 2>/dev/null || true
    ''}

    APP_DIR="${placeholder "out"}/lib/${pname}"
    ${fontInitBlock}
    ${installBlock}
    WRAPPER
    chmod +x $out/bin/${pname}

    # Desktop entry.
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=${desktopName}
    Comment=${description}
    Exec=$out/bin/${pname}
    Categories=${categories};
    Terminal=false
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "${desktopName} (Windows app via Wine)";
    homepage = "https://www.winehq.org/";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = pname;
  };
}
