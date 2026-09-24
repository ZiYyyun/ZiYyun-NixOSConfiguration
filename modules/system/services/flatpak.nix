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
    # nix-flatpak renders each remote into
    #   flatpak remote-add --system --if-not-exists <name> <location>
    # `location` may be a direct repo URL (preferred) or a .flatpakrepo file.
    #
    # Use the USTC Flathub cache as the repo URL. Important: nix-flatpak only
    # runs `remote-add --if-not-exists` and never `remote-modify`, so the URL
    # is fixed the first time the remote is created. If flathub was already
    # added from a different URL (e.g. the old SJTU .flatpakrepo, whose
    # Url= still resolved to dl.flathub.org), the running system must be
    # corrected once manually:
    #   sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
    remotes = [
      {
        name = "flathub";
        location = "https://mirrors.ustc.edu.cn/flathub";
      }
    ];

    # Do not update existing Flatpak apps during every system activation.
    update.onActivation = false;
  };
}