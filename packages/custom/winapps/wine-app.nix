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
  # CJK font for Wine. NB: must be a font Wine's text engine can actually
  # rasterise — wqy-zenhei/wqy-microhei (TrueType collections) hit Wine's
  # "unsupported font format" path and render every CJK glyph as a box;
  # Noto Sans CJK parses cleanly and renders. Register it under its REAL
  # family name ("Noto Sans CJK SC"), otherwise font substitution can't
  # resolve it and Wine falls back to the bitmap "System" font (boxes).
  cjkFont ? pkgs.noto-fonts-cjk-sans,
  forceX11 ? false,          # force the X11 driver (XWayland): fixes window
                             # interaction for apps whose windows misbehave
                             # under the native Wayland driver (e.g. Red Spider
                             # broadcast window cannot be clicked/dragged)
  dontStrip ? false,         # skip stdenv's stripPhase. PE binaries must not
                             # be processed by GNU strip: for PyInstaller
                             # onefile apps (e.g. LuaTools) strip removes the
                             # PKG archive appended after the bootloader,
                             # leaving a broken bootloader-only exe.
  wineArch ? null,           # WINEPREFIX architecture: "win32" | "win64" |
                             # null = keep the prefix's existing arch. 64-bit
                             # apps (e.g. LuaTools, a PE32+ x86-64 exe) MUST
                             # use a win64 prefix, which needs winePkg (WoW64)
                             # and WINEARCH=win64 at prefix creation time.
  windowsVersion ? "win10",  # wine 模拟的 Windows 版本（默认 win10，替代默认
                             # WinXP 的简陋视觉/行为风格）。可在 winecfg 改。
}:

assert mode == "extract" -> mainExe != null;
assert mode == "firstrun-install" -> (installer != null || installCmd != null);

let
  fontFile = "${cjkFont}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc";

  # CJK font injection: runs on every launch until the marker exists, so it
  # also repairs prefixes created before this feature.
  #
  # The recipe below is the one that actually works under Wine (verified with
  # LuaTools, a wxPython app that draws its UI with the bitmap "System" font):
  #   - copy Noto Sans CJK into the prefix (the file name is irrelevant, the
  #     REGISTRY name is what matters);
  #   - register it under its REAL family name "Noto Sans CJK SC" in BOTH the
  #     64-bit and Wow6432Node registry views (a mismatched family name makes
  #     Wine fall back to "System Regular", i.e. boxes again);
  #   - substitute every common CJK / bitmap default font name (宋体, 黑体,
  #     雅黑, SimSun, Tahoma, System, MS Sans Serif, MS Shell Dlg, ...) to it.
  #   - add a FontLink (SystemLink) for "System" as a secondary fallback.
  fontInitBlock = ''
    if [ ! -f "$WINEPREFIX/.cjk-fonts-installed" ]; then
      wineboot -u >/dev/null 2>&1 || true
      FONTS_DIR="$WINEPREFIX/drive_c/windows/Fonts"
      mkdir -p "$FONTS_DIR"
      cp "${fontFile}" "$FONTS_DIR/NotoSansCJK.ttc"
      # Mono CJK face for the console (cmd.exe): the GUI must use a
      # proportional font, but console apps need a monospace face or columns
      # misalign and look terrible ("辣眼睛"). Noto Sans Mono CJK SC covers
      # both ASCII and CJK at fixed width.
      cp "${cjkFont}/share/fonts/opentype/noto-cjk/NotoSansMonoCJK-VF.otf.ttc" "$FONTS_DIR/NotoSansMonoCJK.ttc"
      for FONTVIEW in "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" \
                      "HKLM\\Software\\Wow6432Node\\Microsoft\\Windows NT\\CurrentVersion"; do
        wine reg add "$FONTVIEW\\Fonts" /v "Noto Sans CJK SC (TrueType)" /d "C:\\windows\\Fonts\\NotoSansCJK.ttc" /f >/dev/null 2>&1 || true
        wine reg add "$FONTVIEW\\Fonts" /v "Noto Sans Mono CJK SC (TrueType)" /d "C:\\windows\\Fonts\\NotoSansMonoCJK.ttc" /f >/dev/null 2>&1 || true
        # Keep the bitmap "System" font for Latin (preserves metrics/layout),
        # but let Chinese glyphs fall back to Noto.
        wine reg add "$FONTVIEW\\FontLink\\SystemLink" /v "System" /d "NotoSansCJK.ttc,Noto Sans CJK SC\\0" /f >/dev/null 2>&1 || true
        # Map every common CJK + bitmap/default font name to Noto so GBK-era
        # apps (FeiQ, Red Spider, LuaTools) render Chinese even when they
        # request 宋体/黑体/雅黑/System/MS Sans Serif etc.
        for SUB in System "MS Sans Serif" "MS Serif" "Small Fonts" Modern Roman Script Tahoma "Tahoma Bold" Arial "Arial Black" "Segoe UI" "Segoe UI Bold" "Times New Roman" "Microsoft Sans Serif" Calibri Verdana Georgia SimSun NSimSun SimSun-ExtB SimSun-18030 "MS Song" "宋体" "新宋体" "宋体-18030" SimHei "黑体" "Microsoft YaHei" "微软雅黑" "Microsoft YaHei UI" KaiTi "楷体" "楷体_GB2312" FangSong "仿宋" "仿宋_GB2312" PMingLiU MingLiU DFKai-SB "MingLiU_HKSCS" "SimSun-PUA" DengXian "等线" "MS Shell Dlg" "MS Shell Dlg 2"; do
          wine reg add "$FONTVIEW\\FontSubstitutes" /v "$SUB" /d "Noto Sans CJK SC" /f >/dev/null 2>&1 || true
        done
        # Console fonts must stay monospaced -> route them to the Mono face.
        for SUB in "Courier New" "Courier New Bold" Courier "Terminal" Fixedsys Consolas "Consolas Bold" "Lucida Console" "Lucida Sans Typewriter"; do
          wine reg add "$FONTVIEW\\FontSubstitutes" /v "$SUB" /d "Noto Sans Mono CJK SC" /f >/dev/null 2>&1 || true
        done
      done
      # Make cmd.exe use the mono CJK face (fixed-pitch) instead of the
      # default Lucida Console (no CJK glyphs).
      wine reg add "HKCU\\Console" /v FaceName /d "Noto Sans Mono CJK SC" /f >/dev/null 2>&1 || true
      wine reg add "HKCU\\Console" /v FontFamily /d "0" /t REG_DWORD /f >/dev/null 2>&1 || true
      wine reg add "HKCU\\Console" /v FontWeight /d "400" /t REG_DWORD /f >/dev/null 2>&1 || true
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
  inherit pname version src dontStrip;

  nativeBuildInputs = [ pkgs.unzip ] ++ extraNativeBuildInputs;
  unpackPhase = if unpackPhase != null then unpackPhase else null;

  buildPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname} $out/bin $out/share/applications

    # Copy unpacked source (zip archives are unpacked by default unpackPhase;
    # single exe files land in $PWD as-is). NB: `basename $src` is the full
    # "<hash>-<name>" store path basename, never a file in $PWD, so the else
    # branch below is the one that actually runs.
    if [ -f "$PWD/$(basename $src)" ] && ! [ -d "$PWD/$(basename $src)" ]; then
      cp "$PWD/$(basename $src)" $out/lib/${pname}/
    else
      cp -rT "$PWD" $out/lib/${pname}/ 2>/dev/null || true
    fi
    # Drop the stdenv-generated environment dump if it leaked in via the
    # wholesale copy above; it is never part of the app.
    rm -f $out/lib/${pname}/env-vars
    ${preInstall}

    # Launcher wrapper.
    cat > $out/bin/${pname} <<'WRAPPER'
    #!/usr/bin/env bash
    set -e
    export WINEPREFIX="''${WINEPREFIX:-$HOME/.local/share/winapps/${pname}}"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree,mshtml=d"
    export WINEFSYNC=1
    export WINEDEBUG=-all
    # Use the packaged WoW64-capable wine (winePkg) instead of whatever `wine`
    # happens to be on PATH: home-manager installs a wine whose prefixes
    # default to win32 and that cannot launch 64-bit apps (e.g. LuaTools).
    export PATH="${winePkg}/bin:$PATH"
    ${lib.optionalString (wineArch != null) "export WINEARCH=${wineArch}"}
    mkdir -p "$WINEPREFIX"
    # 模拟 Windows 版本（默认 win10，替代默认 WinXP 的简陋风格）
    wine reg add "HKCU\\Software\\Wine" /v Version /d "${windowsVersion}" /f >/dev/null 2>&1 || true
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
