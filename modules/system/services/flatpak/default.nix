/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: Flatpak 基础配置 + 分类应用聚合。
 *
 * Flatpak 应用按用途拆分，便于按需启用/裁剪：
 *   - daily.nix   日常/社交/娱乐
 *   - dev.nix     开发/专业工具
 *   - office.nix  办公/文档/笔记
 */
{ ... }:

{
  imports = [
    ./daily.nix
    ./dev.nix
    ./office.nix
  ];

  # nix-flatpak provides the services.flatpak options used here.
  services.flatpak = {
    enable = true;

    # This replaces the default remote, so keep the name flathub explicit.
    remotes = [
      {
        name = "flathub";
        location = "https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo";
      }
    ];

    # Do not update existing Flatpak apps during every system activation.
    update.onActivation = false;
  };
}
