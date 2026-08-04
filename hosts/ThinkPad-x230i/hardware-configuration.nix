/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: ThinkPad X230i filesystem layout.
 */
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
  };
}
