/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: VirtualBox/default Niri filesystem layout.
 */
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/sda2";
    fsType = "ext4";
  };
}
