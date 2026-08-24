/**
 * File: luatools.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: 合宙 (OpenLuat) LuaTools 官方调试/烧录工具，Wine 打包。
 *
 * LuaTools_v3.exe 是 PyInstaller 打成的绿色单文件（Python + wxPython），
 * 无需安装即可运行，但它会在 exe 所在目录创建 _temp/config/log/resource/
 * project 等文件夹（见官方文档），因此不能直接放在只读的 nix store 里。
 *
 * 处理方式：firstrun-install 模式，首次启动时把 exe 复制到
 * $WINEPREFIX/drive_c/Luatools/（可写），再从这里启动 —— 与官方
 * “在 D 盘新建 LuaTools 文件夹再放入 exe” 的安装方式等价。
 *
 * 注意：烧录/串口需要把 USB 设备透传给 Wine（wine 的 usb/serial 支持），
 * 这是运行时配置，不在此打包范围内。
 *
 * 来源：https://docs.openluat.com/common/Luatools/  （直链 luatos.com/luatools/download/last）
 */
{ pkgs, callPackage }:
let
  mkWineApp = callPackage ./wine-app.nix { };
  src = pkgs.fetchurl {
    name = "Luatools_v3.exe";
    url = "https://luatos.com/luatools/download/last";
    sha256 = "sha256-iquekiUinyJeMTnN1PCS+KbNLYtRyBgGKIjUn4MmOzI=";
  };
in
mkWineApp {
  pname = "luatools";
  version = "3.4.6"; # docs 记录的最新版（2026.08.21）；Luatools 首启可自更新
  inherit src;
  mode = "firstrun-install";
  # LuaTools 是 64 位 PE32+ exe，必须用 win64 前缀（win32 前缀会报
  # "EXE 格式无效"）。wrapper 会用 winePkg（WoW64）并以 WINEARCH=win64
  # 创建前缀；旧前缀需删除后重建。
  wineArch = "win64";
  # PyInstaller onefile 的 PKG 归档追加在 exe 末尾，GNU strip 会把它剥掉，
  # 只剩引导头（307KB），所以必须跳过 stripPhase。
  dontStrip = true;
  # 单文件 exe：放进构建目录（默认 unpack 不识别 exe）。
  unpackPhase = "cp ${src} Luatools_v3.exe";
  # 复制到可写前缀（等价官方“放入 LuaTools 文件夹”）。
  installCmd = ''
    mkdir -p "$WINEPREFIX/drive_c/Luatools"
    cp "$APP_DIR/Luatools_v3.exe" "$WINEPREFIX/drive_c/Luatools/"
  '';
  exeSearchDir = "Luatools";
  desktopName = "LuaTools";
  description = "合宙 LuatOS 官方调试/烧录工具（Windows, via Wine）";
  categories = "Development";
}
