/**
 * File: winboat.nix
 * Author: ziyun
 * Date: 2026-08-11
 * Description: Docker/KVM prerequisites for the WinBoat desktop application.
 */
{ pkgs, ... }:
{
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
