/**
 * File: compiler-packages.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Reusable package groups for Programming Toolchains.
 */
{ pkgs }:
rec {
  programmingCommon = with pkgs; [
    git
    gnumake
    cmake
    ninja
    pkg-config
  ];

  cFamily = programmingCommon ++ (with pkgs; [
    clang
    clang-tools
    gcc
    glibc
    glibc.dev
    linuxHeaders
    libmodbus
    pkgs."paho-mqtt-c"
    openssl
    zlib
    gdb
    lldb
    bear
    valgrind
    boost
    fmt
    spdlog
  ]);

  rust = programmingCommon ++ (with pkgs; [
    rustup
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
    openssl
    gcc
  ]);

  python = programmingCommon ++ (with pkgs; [
    python3
    uv
    ruff
    pyright
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.ipython
    gcc
  ]);

  node = with pkgs; [
    nodejs
    pnpm
    yarn
    typescript
    typescript-language-server
    prettier
    eslint
    
  ];

  go = [
    pkgs.go
    pkgs.gopls
    pkgs.delve
    pkgs.gotools
    pkgs.golangci-lint
  ];

  java = with pkgs; [
    jdk
    maven
    gradle
    jdt-language-server
  ];

  dotnet = with pkgs; [
    dotnet-sdk
    csharp-ls
  ];
}
