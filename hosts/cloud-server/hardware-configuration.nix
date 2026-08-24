/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: 云服务器（x86_64, UEFI）磁盘布局模板。
 *
 * !!! 部署前必须替换占位值 !!!
 * 在服务器上用 `nixos-generate-config --root /mnt` 生成真实配置，或
 * 用 `blkid` / `lsblk -f` 查真实设备/UUID 后替换下面所有 REPLACE_* 占位符，
 * 否则系统无法挂载磁盘、无法启动。
 */
{ lib, ... }:
{
  # KVM/云主机常见 virtio 磁盘驱动；物理机可去掉 virtio_* 模块。
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "usb_storage"
    "sd_mod"
  ];

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-uuid/REPLACE_WITH_ROOT_UUID";
    fsType = "ext4";
  };

  # UEFI 引导分区（云镜像如有独立 ESP；若 UEFI 直启根分区则删除本段）。
  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-uuid/REPLACE_WITH_ESP_UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # 无 swap 的云主机可整段删除。
  swapDevices = lib.mkDefault [
    { device = "/dev/disk/by-uuid/REPLACE_WITH_SWAP_UUID"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
