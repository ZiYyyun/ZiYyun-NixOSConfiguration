/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Default KDE filesystem layout for the test VM.
 */
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
