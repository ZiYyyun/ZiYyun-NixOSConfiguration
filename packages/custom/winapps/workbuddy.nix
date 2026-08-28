/**
 * File: workbuddy.nix
 * Author: ziyun
 * Date: 2026-08-28
 * Description: 腾讯 WorkBuddy（AI 办公工作台）Windows 版，Wine 打包（备选方案）。
 *
 * 注意：WorkBuddy Windows 版是 Electron 应用（electron-builder NSIS 安装器，
 * 文件名 win32-x64-user 即 per-user 安装模式）。Electron 的 Chromium 在 Wine 下
 * 基本无法运行（GPU/沙箱/Node 集成均不受支持），此包大概率无法正常启动，
 * 仅作为「官方无 Linux 版」时的备选占位。推荐使用 Waydroid 跑 Android 版。
 *
 * 安装：首次启动静默安装到 Wine 前缀（user 模式 → %LOCALAPPDATA%\Programs），
 * 因目录含用户名，用 exeSearchDir=users 宽泛搜索。
 *
 * 来源：官方历史版本页 https://www.workbuddy.cn/docs/workbuddy/Download-History
 *   v5.1.2 (2026-06-17) win32-x64-user, 485.8MB
 */
{ pkgs, callPackage }:
let
  mkWineApp = callPackage ./wine-app.nix { };
  src = pkgs.fetchurl {
    name = "WorkBuddySetup.exe";
    url = "https://download.codebuddy.cn/workbuddy/saas/win32-x64-user/WorkBuddy-win32-x64-user-5.1.2.30975940-b9604175.exe";
    sha256 = "2c865b3454439284baa139a60808f76c8c7d82a282dc795bd9cd54a24db09a76";
  };
in
mkWineApp {
  pname = "workbuddy";
  version = "5.1.2";
  inherit src;
  mode = "firstrun-install";
  installer = "WorkBuddySetup.exe";
  installerArgs = "/S";
  # 单文件 exe：stdenv 默认 unpack 不识别 .exe，直接复制到构建目录
  unpackPhase = "cp ${src} WorkBuddySetup.exe";
  # 64 位 Electron 应用：必须 win64 前缀（WoW64 wine）
  wineArch = "win64";
  # PE 文件不可被 GNU strip 处理
  dontStrip = true;
  # user 安装器装到 %LOCALAPPDATA%\Programs\<app>，宽泛搜索 drive_c/users
  exeSearchDir = "users";
  desktopName = "WorkBuddy";
  description = "腾讯 WorkBuddy AI 办公工作台（Windows via Wine，Electron 兼容性差，备选方案）";
  categories = "Office;";
}
