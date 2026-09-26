/**
 * File: linyaps.nix
 * Author: ziyun
 * Date: 2026-09-25
 * Description: 如意玲珑（Linyaps）跨发行版包管理器。
 *
 * 由 nixpkgs 的 services.linyaps 模块提供（nixpkgs 25.11+），启用后自动安装：
 *   - linyaps        → ll-cli（安装/运行/卸载玲珑应用）
 *   - linyaps-box    → 沙箱运行时
 *   - linyaps-web-store-installer → ll-installer（网页商店 URI handler）
 *
 * 图形化用法：打开 https://store.linyaps.org.cn 网页商店，点击应用「安装」，
 * 浏览器会调起本地 ll-installer 自动执行安装，无需命令行。
 * 社区版 Tauri 图形商店（linglong-store）未被 nixpkgs 收录，需手动脚本安装，
 * 非声明式，不建议在 NixOS 上使用。
 */
{ ... }:

{
  services.linyaps.enable = true;
}
