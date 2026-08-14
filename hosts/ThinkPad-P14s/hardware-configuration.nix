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
    "usb_storage"
    "uas"
    "sd_mod"
  ];

  fileSystems."/" = {
    # Physical install target: the dedicated SATA disk is expected to appear as
    # /dev/sda, so use direct device paths instead of UUIDs for this profile.
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
