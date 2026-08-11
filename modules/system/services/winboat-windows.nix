/**
 * File: winboat-windows.nix
 * Author: ziyun
 * Date: 2026-08-11
 * Description: Declarative Docker/KVM backend for WinBoat's Windows VM.
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

  environment.etc."winboat/compose.yml".source = ../../../winboat/compose.yml;

  systemd.tmpfiles.rules = [
    "d /var/lib/winboat 0750 root docker -"
    "d /var/lib/winboat/windows 0770 root docker -"
    "d /var/lib/winboat/shared 0770 root docker -"
    "d /var/lib/winboat/iso 0770 root docker -"
  ];

  systemd.services.winboat-windows = {
    description = "WinBoat Windows VM backend powered by dockurr/windows";
    documentation = [
      "https://github.com/dockur/windows"
      "https://github.com/TibixDev/winboat"
    ];
    wantedBy = [ "multi-user.target" ];
    after = [
      "docker.service"
      "network-online.target"
    ];
    wants = [
      "docker.service"
      "network-online.target"
    ];

    path = with pkgs; [
      docker
      docker-compose
    ];

    preStart = ''
      docker-compose -f /etc/winboat/compose.yml pull || true
    '';

    script = ''
      exec docker-compose -f /etc/winboat/compose.yml up --remove-orphans
    '';

    preStop = ''
      docker-compose -f /etc/winboat/compose.yml down --remove-orphans
    '';

    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
      TimeoutStartSec = "30min";
      TimeoutStopSec = "2min";
    };
  };
}
