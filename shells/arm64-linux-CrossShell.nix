/**
 * File: arm64-linux.nix
 * Author: ZiYyun
 * Date: 2026-07-31
 * Description:
 *   ARM64 Linux cross-compiling development shell.
 *
 *   Supported platforms:
 *     - Rockchip RK3568
 *     - Rockchip RK3588
 *     - Other ARMv8 Linux SoCs
 */

let
  pkgs = import <nixpkgs> {
    crossSystem =
      (import <nixpkgs/lib>).systems.examples.aarch64-multiplatform;
  };
in

pkgs.mkShell {

  buildInputs = with pkgs; [

    # Toolchain
    #gcc
    binutils
    #gdb

    # Build
    gnumake
    cmake
    ninja
    pkg-config
    #git

    # Utilities
    #python3
    dtc
    ubootTools
    file

    # Libraries
    zlib
  ];

  shellHook = ''
    export ARCH=arm64
    export CROSS_COMPILE=${pkgs.stdenv.cc.targetPrefix}

    echo ""
    echo "========================================="
    echo " ARM64 Linux Cross Compile Environment"
    echo "========================================="
    echo " Target         : ${pkgs.stdenv.targetPlatform.config}"
    echo " ARCH           : $ARCH"
    echo " CROSS_COMPILE  : $CROSS_COMPILE"
    echo "========================================="
    echo ""
  '';
}