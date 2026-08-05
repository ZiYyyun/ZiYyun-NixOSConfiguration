/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad P14s filesystem layout.
 */
{ ... }:
{
  boot.initrd.availableKernelModules = [ "uas" "usb_storage" "sd_mod" ];

  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };
}
