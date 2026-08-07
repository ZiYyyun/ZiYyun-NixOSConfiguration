{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "cpp";
  packages = with pkgs; [
    clang
    clang-tools
    glibc
    glibc.dev
    linuxHeaders
    gdb
    lldb
    cmake
    gnumake
    ninja
    pkg-config
    bear
    valgrind
    boost
    fmt
    spdlog
  ];
  env = {
    CC = "clang";
    CXX = "clang++";
    CPATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    C_INCLUDE_PATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    CPLUS_INCLUDE_PATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    LIBRARY_PATH = "${pkgs.glibc}/lib";
  };
  message = "C++ shell: clang/clangd, glibc headers, common C++ libraries, CMake/Ninja, gdb/lldb. Generate compile_commands.json for best clangd results.";
}
