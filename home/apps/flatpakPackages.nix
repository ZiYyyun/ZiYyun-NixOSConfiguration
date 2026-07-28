# ./modules/flatpak.nix
{ config, pkgs, lib, ... }:

{
  # 启用 Flatpak 并声明要安装的包
  services.flatpak = {
    enable = true;

    # 要安装的 Flatpak 应用（默认从 flathub 安装最新版）
    packages = [
      # "org.blender.Blender"
      # "com.spotify.Client"
      # "org.mozilla.firefox"
      # 按需添加更多
    ];

    # 可选：添加远程仓库（默认已添加 flathub，但可显式声明）
    remotes = [
      {
        name = "flathub";
        # location = "https://mirrors.ustc.edu.cn/flathub";
        location = "https://mirror.sjtu.edu.cn/flathub";
      }
    ];

    # 可选：系统更新时不自动更新 Flatpak（保持复现性）
    update.onActivation = false;   # 默认 true
  };


# systemd.services.flatpak-managed-install = {
#   serviceConfig = {
#     TimeoutStartSec = lib.mkForce "300";
#     Restart = lib.mkForce "no";
#     RestartSec = lib.mkForce "0";
#   };
#   after = [ "network-online.target" ];
#   wants = [ "network-online.target" ];
# };


  # 可选：允许非 root 用户安装 Flatpak（默认已允许）
  # services.flatpak.user = true;
}