/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: 云服务器 host profile（无界面，x86_64，UEFI）。
 *
 * 部署：
 *   1. 在服务器上按 hardware-configuration.nix 的注释填好磁盘布局（或
 *      直接用 `nixos-generate-config --root /mnt` 生成真实配置覆盖）。
 *   2. 本机执行：sudo nixos-rebuild switch --flake .#cloud-server
 *
 * 1Panel：NixOS 无官方包，后续要装时先取消下面 Docker 注释，再决定
 * 用官方 quick_start.sh 或打包成 Nix 包。
 */
{ lib, pkgs, ... }:
{
  imports = [
    ../common/hardware-configuration.nix
    ../common/boot/uefi.nix
    ./hardware-configuration.nix
  ];

  # 云服务器：无图形界面，不 import 桌面 profile。

  # 全局 configuration.nix 默认 hostName = "nixos"，这里覆盖为服务器名。
  networking.hostName = lib.mkForce "cloud-server";

  # 防火墙：公网服务器只开 SSH。全局配置里为飞秋/红蜘蛛开的 LAN 端口
  # （TCP/UDP 2425、1688-1691）必须清掉。
  networking.firewall.allowedTCPPorts = lib.mkForce [ 22 ];
  networking.firewall.allowedUDPPorts = lib.mkForce [ ];

  # 全局 configuration.nix 装了 firefox（桌面用），无界面服务器不需要。
  programs.firefox.enable = lib.mkForce false;

  # 基础运维工具。
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    tmux
    ripgrep
  ];

  # Docker（1Panel 前置依赖，后续需要时启用）。
  # virtualisation.docker.enable = true;

  # SSH 加固建议（先在服务器放好公钥再开，避免锁死）：
  # services.openssh.settings.PasswordAuthentication = false;
  # services.openssh.settings.PermitRootLogin = "no";
}
