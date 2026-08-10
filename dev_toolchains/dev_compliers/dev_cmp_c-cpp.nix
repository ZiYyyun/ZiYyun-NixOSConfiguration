{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "c-cpp";
  packages = devCmpPackages.cFamily;
  env = {
    CC = "clang";
    CXX = "clang++";
    CPATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    C_INCLUDE_PATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    CPLUS_INCLUDE_PATH = "${pkgs.glibc.dev}/include:${pkgs.linuxHeaders}/include";
    LIBRARY_PATH = "${pkgs.glibc}/lib";
  };
  message = "C/C++ shell: clang/clangd, glibc headers, pthread support, libmodbus, Eclipse Paho MQTT C, OpenSSL/Zlib, CMake/Ninja, gdb/lldb. Use -pthread for pthread code.";
}
