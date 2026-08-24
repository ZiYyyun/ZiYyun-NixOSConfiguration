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

  # Lua: interpreter + tooling built on top of the shared C toolchain (cFamily).
  # LuatOS 开发既写 Lua 脚本、又编 C 原生模块/CSDK，因此直接复用 cFamily
  # 而不是重复定义编译器与库 —— 这就是本组的 import 关系。`lua` 命令解析到
  # lua5_4（列表在前），LuaJIT 用 `luajit` 显式调用；luarocks/luacheck/luaunit
  # 统一取 lua5_4.pkgs，避免混用默认 5.2 的版本。
  lua = cFamily ++ (with pkgs; [
    lua5_4
    luajit
    lua-language-server
    lua5_4.pkgs.luarocks
    lua5_4.pkgs.luacheck
    lua5_4.pkgs.luaunit
  ]);
}
