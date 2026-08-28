/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-20
 * Description: Windows apps packaged with Wine (winapps).
 */
{ callPackage }:

{
  feiq = callPackage ./feiq.nix { };
  redspider-student = callPackage ./redspider.nix { };
  # 合宙 LuatOS 官方调试/烧录工具（LuaTools_v3.exe，PyInstaller 绿色单文件）。
  luatools = callPackage ./luatools.nix { };
  # 腾讯 WorkBuddy（Electron，Wine 备选方案，兼容性差）。
  workbuddy = callPackage ./workbuddy.nix { };
}
