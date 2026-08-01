{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rustc
    rustup
    cargo

    python3

    clang
    gcc
    gdb
    cmake
    gnumake
    ninja
    pkg-config

    perl
  ];
}
