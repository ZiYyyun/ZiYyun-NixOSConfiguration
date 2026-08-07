{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "c";
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
  ];
  env = {
    CC = "clang";
    CXX = "clang++";
    CPATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    C_INCLUDE_PATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    LIBRARY_PATH = "${pkgs.glibc}/lib";
  };
  message = "C shell: clang/clangd, glibc headers, pthread support, CMake/Ninja, gdb/lldb. Use -pthread when compiling pthread code.";
}
