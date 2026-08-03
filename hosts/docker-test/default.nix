/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Build/test hardware overrides for evaluating this NixOS config in container-like environments.
 */
{ lib, ... }:
{
  # This profile is for evaluating/building the system closure without relying
  # on the real machine's disks or bootloader. It is not a full Docker image.
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" ];
  };

  swapDevices = lib.mkForce [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
