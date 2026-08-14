/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Default Niri filesystem layout.
 */
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
