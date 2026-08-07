/**
* File: embedded.nix
* Author: ziyun
* Date: 2026-07-29
* Description: Lightweight embedded tools kept globally available.
*/
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openocd
    probe-rs-tools
    dfu-util
    libusb1

    minicom
    picocom
    screen
    usbutils
  ];
}
