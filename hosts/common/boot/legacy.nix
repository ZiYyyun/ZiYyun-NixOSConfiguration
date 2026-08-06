/**
 * File: legacy.nix
 * Author: ziyun
 * Date: 2026-08-06
 * Description: Legacy BIOS bootloader profile based on GRUB.
 */
{ lib, ... }:
{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = lib.mkDefault "/dev/sda";
  };
}
