/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad P14s Gen 5 Intel filesystem layout.
 */
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ "uas" "usb_storage" "sd_mod" ];

  # Replace these device paths with /dev/disk/by-uuid/... after running
  # nixos-generate-config on the real P14s. Plain /dev/sdX names are not
  # stable across physical disks, USB installers, and virtual disks.
  boot.loader.grub.device = lib.mkDefault "/dev/sda";

  fileSystems."/" = {
    device = lib.mkDefault "/dev/sda1";
    fsType = "ext4";
  };

  swapDevices = lib.mkDefault [ ];
}
