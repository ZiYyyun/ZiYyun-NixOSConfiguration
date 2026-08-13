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
    "ehci_pci"
    "ahci"
    "ata_piix"
    "vmd"
    "nvme"
    "usb_storage"
    "uas"
    "sd_mod"
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
  ];

  fileSystems."/" = {
    device = lib.mkDefault "/dev/disk/by-uuid/01c7eef3-3d1c-40c2-bcb2-300bd82e4c73";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = lib.mkDefault "/dev/disk/by-uuid/4025-3FB4";
    fsType = "vfat";
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/disk/by-uuid/21cb3e46-4e54-4758-afa0-6d7e4ec6c818"; }
  ];
}
