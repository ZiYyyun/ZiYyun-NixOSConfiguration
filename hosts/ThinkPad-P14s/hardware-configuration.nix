/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad P14s Gen 5 Intel filesystem layout.
 */
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  fileSystems."/" = {
    # Physical install target: the dedicated SATA disk is expected to appear as
    # /dev/sda, so use direct device paths instead of UUIDs for this profile.
    device = lib.mkDefault "/dev/disk/by-uuid/103df489-46c9-4d5f-b7d7-580965585556";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = lib.mkDefault "/dev/disk/by-uuid/01F7-705E";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/disk/by-uuid/d9afbe49-e8a3-440a-8854-cc5fd0608c15"; }
  ];
}
