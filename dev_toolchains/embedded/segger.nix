/**
 * File: segger.nix
 * Author: ziyun
 * Date: 2026-08-11
 * Description: SEGGER helper shell for manually installed J-Link tools.
 */
{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
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

  packages = embeddedPackages.segger ++ [
    jlinkLauncher
  ];

  shellHook = ''
    export SEGGER_VENDOR="SEGGER"
    export SEGGER_JLINK_HOME="''${SEGGER_JLINK_HOME:-$HOME/SEGGER/JLink}"

    echo ""
    echo "========================================="
    echo " segger"
    echo "========================================="
    echo "Tools:"
    echo "  - steam-run"
    echo "  - jlink-exe"
    echo "SEGGER Embedded Studio is not provided by this devShell."
    echo "Reason: the official Studio download requires license-gated installation and is not a normal nixpkgs package."
    echo "Run: jlink-exe"
    echo "========================================="
    echo ""
  '';
}
