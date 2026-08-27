/**
 * File: winboat.nix
 * Author: ziyun
 * Date: 2026-08-11
 * Description: Docker/KVM prerequisites for the WinBoat desktop application.
 *
 * 2026-08-25 修复：winboat 从 trae/vscode 派生的终端启动时会继承父进程
 * 泄漏的 ELECTRON_RUN_AS_NODE 等环境变量，导致 electron 以纯 Node 运行、
 * require('electron') 失败（SyntaxError: ... does not provide an export
 * named 'BrowserWindow'），winboat 启动即崩。用 overlay 给 winboat 的
 * wrapper 加 unset，保证从任何终端/KDE 菜单启动都正常。
 */
{ pkgs, ... }:
{
  # winboat 的 wrapper 启动前清掉 trae/vscode 泄漏的 electron 环境变量。
  nixpkgs.overlays = [
    (final: prev: {
      winboat = prev.winboat.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          sed -i '2i unset ELECTRON_RUN_AS_NODE ELECTRON_DISABLE_SANDBOX ELECTRON_FORCE_IS_PACKAGED VSCODE_RUN_IN_ELECTRON ICUBE_IS_ELECTRON ICUBE_ELECTRON_PATH DISABLE_GPU_SANDBOX' \
            "$out/bin/winboat"
        '';
      });
    })
  ];

  boot.kernelModules = [
    "kvm-intel"
    "tun"
  ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  users.users."ziyun".extraGroups = [
    "docker"
    "kvm"
    "libvirtd"
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
    virt-manager
  ];
}
