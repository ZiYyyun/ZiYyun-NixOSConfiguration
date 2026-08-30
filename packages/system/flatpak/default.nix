/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: Flatpak 应用清单入口（按用途分类聚合）。
 *
 * Flatpak 应用按用途拆分，便于按需启用/裁剪：
 *   - daily.nix   日常/社交/娱乐
 *   - dev.nix     开发/专业工具
 *   - office.nix  办公/文档/笔记
 *
 * 仅声明 services.flatpak.packages；flatpak 服务本身的启用与仓库配置
 * 在 modules/system/services/flatpak.nix。
 */
{ ... }:
{
  imports = [
    ./daily.nix
    ./dev.nix
    ./office.nix
  ];
}