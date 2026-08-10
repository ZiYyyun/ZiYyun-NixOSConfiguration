{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
  cLibraryPackages = [
    pkgs.glibc
    pkgs.libmodbus
    pkgs."paho-mqtt-c"
    pkgs.openssl
    pkgs.zlib
    pkgs.boost
    pkgs.fmt
    pkgs.spdlog
  ];
  cIncludePackages = [
    (pkgs.lib.getDev pkgs.glibc)
    pkgs.linuxHeaders
  ] ++ map pkgs.lib.getDev cLibraryPackages;
  cIncludePath = pkgs.lib.makeSearchPath "include" cIncludePackages;
  cLibraryPath = pkgs.lib.makeLibraryPath cLibraryPackages;
  cPkgConfigPath = pkgs.lib.makeSearchPath "lib/pkgconfig" cIncludePackages;
in
mkDevCmpShell {
  inherit pkgs;
  name = "c-cpp";
  packages = devCmpPackages.cFamily;
  env = {
    CC = "clang";
    CXX = "clang++";
    CPATH = cIncludePath;
    C_INCLUDE_PATH = cIncludePath;
    CPLUS_INCLUDE_PATH = cIncludePath;
    LIBRARY_PATH = cLibraryPath;
    PKG_CONFIG_PATH = cPkgConfigPath;
    NIX_CFLAGS_COMPILE = builtins.concatStringsSep " " (map (pkg: "-isystem ${pkg}/include") cIncludePackages);
  };
  message = "C/C++ shell: clang/clangd, glibc headers, pthread support, libmodbus, Eclipse Paho MQTT C, OpenSSL/Zlib, CMake/Ninja, gdb/lldb. Use -pthread for pthread code.";
}
