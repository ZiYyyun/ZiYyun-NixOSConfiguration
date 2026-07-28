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

