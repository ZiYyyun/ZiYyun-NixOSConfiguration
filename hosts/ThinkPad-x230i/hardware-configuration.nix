/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad X230i filesystem layout.
 */
{ lib, ... }:
{
  boot.loader.grub.device = lib.mkForce "/dev/sdb";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/122644b7-94dc-4bdc-a727-a6b967928aab";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/41daad12-90ac-404f-b921-ebf93e6e2b8d"; }
  ];
}
