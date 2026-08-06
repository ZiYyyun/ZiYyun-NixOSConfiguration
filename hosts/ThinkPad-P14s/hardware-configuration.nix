/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad P14s filesystem layout.
 */
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ "uas" "usb_storage" "sd_mod" ];

  boot.loader.grub.device = lib.mkForce "/dev/sda";

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/sda2"; }];
}
