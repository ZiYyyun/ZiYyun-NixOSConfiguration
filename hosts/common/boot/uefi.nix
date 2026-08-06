/**
 * File: uefi.nix
 * Author: ziyun
 * Date: 2026-08-06
 * Description: UEFI bootloader profile based on systemd-boot.
 */
{ lib, ... }:
{
  boot.loader.grub.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
