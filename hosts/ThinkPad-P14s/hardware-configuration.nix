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
    # This machine currently exposes the installed disk consistently as sda
    # during early boot. UUID lookup timed out in initrd, so keep the direct
    # root device path until the initrd device discovery issue is isolated.
    device = lib.mkDefault "/dev/sda2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = lib.mkDefault "/dev/sda1";
    fsType = "vfat";
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/sda3"; }
  ];
}
