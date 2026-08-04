/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Desktop PC filesystem layout.
 */
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };
}
