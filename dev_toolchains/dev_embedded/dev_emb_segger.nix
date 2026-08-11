/**
 * File: dev_emb_segger.nix
 * Author: ziyun
 * Date: 2026-08-11
 * Description: SEGGER development shell for J-Link tools and manually installed Embedded Studio.
 */
{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  seggerStudioLauncher = pkgs.writeShellScriptBin "segger-studio" ''
    set -e

    candidates=(
      "''${SEGGER_STUDIO_HOME:-}/bin/emStudio"
      "$HOME/SEGGER/EmbeddedStudio/bin/emStudio"
      "$HOME/SEGGER/SEGGER Embedded Studio/bin/emStudio"
      "$HOME/SEGGER/SEGGER Embedded Studio for ARM/bin/emStudio"
      "/opt/SEGGER/SEGGER Embedded Studio for ARM/bin/emStudio"
      "/opt/SEGGER/EmbeddedStudio/bin/emStudio"
    )

    for exe in "''${candidates[@]}"; do
      if [ -n "$exe" ] && [ -x "$exe" ]; then
        exec steam-run "$exe" "$@"
      fi
    done

    echo "SEGGER Embedded Studio was not found."
    echo "Install it manually, then set SEGGER_STUDIO_HOME to its install directory."
    echo "Example: export SEGGER_STUDIO_HOME=\"/opt/SEGGER/SEGGER Embedded Studio for ARM\""
    exit 1
  '';
  jlinkLauncher = pkgs.writeShellScriptBin "jlink-exe" ''
    set -e

    candidates=(
      "''${SEGGER_JLINK_HOME:-}/JLinkExe"
      "''${SEGGER_JLINK_HOME:-}/bin/JLinkExe"
      "$HOME/SEGGER/JLink/JLinkExe"
      "/opt/SEGGER/JLink/JLinkExe"
    )

    for exe in "''${candidates[@]}"; do
      if [ -n "$exe" ] && [ -x "$exe" ]; then
        exec steam-run "$exe" "$@"
      fi
    done

    echo "SEGGER J-Link Software was not found."
    echo "Install the SEGGER J-Link Software and Documentation Pack manually,"
    echo "then set SEGGER_JLINK_HOME to its install directory."
    echo "Example: export SEGGER_JLINK_HOME=\"/opt/SEGGER/JLink\""
    exit 1
  '';
in
pkgs.mkShell {
  name = "segger";

  packages = devEmbPackages.segger ++ [
    seggerStudioLauncher
    jlinkLauncher
  ];

  shellHook = ''
    export SEGGER_VENDOR="SEGGER"
    export SEGGER_STUDIO_HOME="''${SEGGER_STUDIO_HOME:-$HOME/SEGGER/SEGGER Embedded Studio for ARM}"
    export SEGGER_JLINK_HOME="''${SEGGER_JLINK_HOME:-$HOME/SEGGER/JLink}"

    echo ""
    echo "========================================="
    echo " segger"
    echo "========================================="
    echo "SEGGER environment: FHS launchers for manual Embedded Studio and J-Link installs."
    echo "Run: segger-studio"
    echo "Run: jlink-exe"
    echo "========================================="
    echo ""
  '';
}
