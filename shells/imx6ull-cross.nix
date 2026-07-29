/**
 * File: imx6ull-cross.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: ARMv7 gnueabihf cross-compiling development shell.
 */
let
  pkgs = import <nixpkgs> {
    crossSystem = (import <nixpkgs/lib>).systems.examples.armv7l-hf-multiplatform;
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    binutils
    zlib
  ];
  shellHook = ''
    echo "Welcome to ARMv7 (gnueabihf) cross-compiling shell"
    export CROSS_COMPILE=armv7l-unknown-linux-gnueabihf-
  '';
}

