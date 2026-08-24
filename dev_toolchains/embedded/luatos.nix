/**
 * File: luatos.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: 合宙 (OpenLuat) LuatOS 开发环境。
 *
 * 复用公共 helper：mkEmbeddedMcuShell（libs/embedded-mcu-shell.nix）+
 * 包组 embedded-packages.nix 的 `luatos` 组，与 stm/esp/nordic 同构。
 *
 * 包含：
 *   - CSDK 工具链：riscv64-none-elf（Air101/Air103 C906）、riscv32-none-elf
 *     （ESP32-C3 等）、arm-none-eabi（Air32F103）
 *   - 烧录/脚本：luatool（加载 init.lua）、luatos-utils（script.img）、esptool
 *   - 通用：串口工具、git/cmake/make、gpsbabel
 *
 * 使用：
 *   nix develop .#luatos
 *   # CSDK: 克隆 luatos-soc-* 后编译（riscv64-unknown-elf-* 别名已就绪）
 *   # 合宙在线测试服务（TCP/UDP/FTP/HTTP/RTMP/MQTT/GPS/量产等）见
 *   # wiki/Dev-Embedded-Toolchains.md 的 LuatOS 小节
 */
{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedMcuShell = import ../libs/embedded-mcu-shell.nix;
  luatosTools = pkgs.callPackage ../../packages/custom/luatos-tools { };
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "luatos";
  packages = embeddedPackages.luatos ++ [
    luatosTools.luatool
    luatosTools.luatosUtils
    luatosTools.luatosCli  # Air780EPM(EC718) 等 Cat.1 模组刷机（luatool 不适用）
  ];
  tools = [
    "riscv64-none-elf-gcc (Air101/Air103)"
    "riscv64-unknown-elf-* 别名"
    "riscv32-none-elf-gcc (ESP32-C3)"
    "arm-none-eabi-gcc (Air32F103)"
    "luatool / mkscriptbin / esptool / luatos-cli"
    "串口: picocom/minicom/screen"
  ];
  libraries = [ ];
  versionCommands = [
    { name = "riscv64-none-elf-gcc"; bin = "riscv64-none-elf-gcc"; command = "riscv64-none-elf-gcc --version"; }
    { name = "riscv32-none-elf-gcc"; bin = "riscv32-none-elf-gcc"; command = "riscv32-none-elf-gcc --version"; }
    { name = "arm-none-eabi-gcc"; bin = "arm-none-eabi-gcc"; command = "arm-none-eabi-gcc --version"; }
    { name = "luatool"; bin = "luatool"; command = "luatool --help"; }
    { name = "esptool"; bin = "esptool"; command = "esptool version"; }
  ];
  message = "LuatOS 开发：CSDK 编译用 riscv64-unknown-elf-* 别名；在线测试服务器与 LuaTools 说明见 wiki/Dev-Embedded-Toolchains.md";
  # 别名逻辑放在独立脚本里（Nix 多行字符串会插值 $VAR，不便内联）。
  extraShellHook = ''
    source ${../../shells/luatos-hook.sh}
  '';
}
