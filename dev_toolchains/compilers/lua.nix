/**
 * File: lua.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: Lua 语言开发环境（含 C 工具链，供 LuatOS 等原生模块开发）。
 *
 * 复用公共 helper：mkCompilerShell（libs/compiler-shell.nix）+ 包组
 * compiler-packages.nix 的 `lua` 组。该组在共享 C 工具链（cFamily）之上
 * 叠加 Lua 解释器/工具链 —— LuatOS 开发脚本用 Lua、原生模块/CSDK 用 C，
 * 所以这里 import 了 cFamily（不重复定义编译器与 C 库）。
 *
 * 包含：
 *   - Lua 解释器：lua5_4（`lua` 命令）、luajit（`luajit` 命令）
 *   - Lua 工具：lua-language-server（sumneko）、luarocks、luacheck、luaunit
 *   - C 工具链（来自 cFamily）：clang/clangd、gcc、gdb/lldb、cmake/ninja、
 *     pkg-config、glibc/openssl/zlib/boost/fmt/spdlog 等
 *
 * 使用：
 *   nix develop .#lua
 *   # 纯 Lua 脚本：lua / luajit
 *   # 原生模块：luarocks make；或直接 gcc -shared -fPIC -I... -o mod.so mod.c
 *   # 完整 LuatOS 开发（烧录/交叉编译）另开：nix develop .#luatos
 */
{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "lua";
  packages = compilerPackages.lua;
  # `;;` 保留默认搜索路径，`./?.lua` 便于直接 require 当前目录模块。
  env = {
    LUA_PATH = "./?.lua;;";
    LUA_CPATH = "./?.so;;";
  };
  tools = [
    "lua (5.4) / luajit"
    "lua-language-server (sumneko)"
    "luarocks / luacheck / luaunit"
    "C: clang / clangd / gcc（原生模块与 LuatOS CSDK）"
  ];
  libraries = [
    "Lua: lua5_4 / luajit 解释器与头文件"
    "C: glibc, openssl, zlib, boost, fmt, spdlog, libmodbus, paho-mqtt-c"
  ];
  versionCommands = [
    { name = "lua"; bin = "lua"; command = "lua -v"; }
    { name = "luajit"; bin = "luajit"; command = "luajit -v"; }
    { name = "lua-language-server"; bin = "lua-language-server"; command = "lua-language-server --version"; }
    { name = "luarocks"; bin = "luarocks"; command = "luarocks --version"; }
    { name = "luacheck"; bin = "luacheck"; command = "luacheck --version"; }
    { name = "clang"; bin = "clang"; command = "clang --version"; }
  ];
  message = "Lua shell: lua5_4 + luajit + lua-language-server + luarocks，并复用 C 工具链（cFamily）编译原生模块；LuatOS 烧录/交叉编译另用 nix develop .#luatos";
}
