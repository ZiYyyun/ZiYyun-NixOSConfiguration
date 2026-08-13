/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad P14s Gen 5 Intel filesystem layout.
 */
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ "uas" "usb_storage" "sd_mod" ];

  fileSystems."/" = {
    # Replace with /dev/disk/by-uuid/... after the UEFI installation finishes.
    device = lib.mkDefault "/dev/sda2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    # UEFI system partition created by the installer.
    device = lib.mkDefault "/dev/sda1";
    fsType = "vfat";
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/sda3"; }
  ];
}
