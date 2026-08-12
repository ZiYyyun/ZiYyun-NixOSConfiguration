{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
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
mkCompilerShell {
  inherit pkgs;
  name = "c-cpp";
  packages = compilerPackages.cFamily;
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
  tools = [
    "clang / clang++"
    "clangd"
    "cmake"
    "ninja"
    "gdb / lldb"
    "pkg-config"
  ];
  libraries = [
    "glibc and linuxHeaders"
    "pthread via glibc; compile with -pthread"
    "libmodbus"
    "paho-mqtt-c"
    "openssl"
    "zlib"
    "boost"
    "fmt"
    "spdlog"
  ];
  versionCommands = [
    { name = "clang"; bin = "clang"; command = "clang --version"; }
    { name = "clangd"; bin = "clangd"; command = "clangd --version"; }
    { name = "cmake"; bin = "cmake"; command = "cmake --version"; }
    { name = "pkg-config"; bin = "pkg-config"; command = "pkg-config --version"; }
  ];
  message = "C/C++ shell: clang/clangd, glibc headers, pthread support, libmodbus, Eclipse Paho MQTT C, OpenSSL/Zlib, CMake/Ninja, gdb/lldb. Use -pthread for pthread code.";
}
