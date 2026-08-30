/**
 * File: flatpak.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: Flatpak 服务启用与仓库配置。
 *
 * 只负责「启用 flatpak 服务 + 配置仓库/更新策略」。
 * Flatpak 应用清单（按用途分类的 daily/dev/office）在
 * packages/system/flatpak/，与其它软件清单放一起。
 */
{ ... }:

{
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