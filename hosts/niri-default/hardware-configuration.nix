/**
 * File: hardware-configuration.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Default Niri filesystem layout for the test VM.
 */
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.initrd.kernelModules = [ "vmwgfx" ];

  services.xserver.videoDrivers = [ "vmware" "modesetting" ];

  virtualisation.virtualbox.guest = {
    enable = true;
    clipboard = true;
    dragAndDrop = true;
  };
}
