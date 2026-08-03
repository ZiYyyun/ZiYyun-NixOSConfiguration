/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: General development module entrypoint.
 */
{ pkgs, ... }:
{
  imports = [
    ./general.nix
    ./embedded.nix
  ];

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
