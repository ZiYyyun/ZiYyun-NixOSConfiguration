/**
* File: arm32-linux.nix
* Author: ZiYyun
* Date: 2026-07-31
* Description:
*   ARMv7 Linux cross-compiling development shell.
*
*   Supported platforms:
*     - NXP i.MX6ULL
*     - Allwinner F1C100S
*     - Allwinner V3S
*     - Allwinner H3
*     - Other ARMv7 Linux SoCs
*/

let
pkgs = import <nixpkgs> {
  crossSystem =
  (import <nixpkgs/lib>).systems.examples.armv7l-hf-multiplatform;
};
in

pkgs.mkShell {
  buildInputs = with pkgs; [

    # Toolchain
    gcc
    binutils
    gdb

    # Build
    gnumake
    cmake
    ninja
    pkg-config
    git

    # Utilities
    python3
    dtc
    ubootTools
    file

    # Libraries
    zlib
  ];

  shellHook = ''
  export ARCH=arm
  export CROSS_COMPILE=${pkgs.stdenv.cc.targetPrefix}

  echo ""
  echo "========================================="
  echo " ARM32 Linux Cross Compile Environment"
  echo "========================================="
  echo " Target         : ${pkgs.stdenv.targetPlatform.config}"
  echo " ARCH           : $ARCH"
  echo " CROSS_COMPILE  : $CROSS_COMPILE"
  echo "========================================="
  echo ""
  '';
}
