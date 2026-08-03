/**
* File: embedded.nix
* Author: ziyun
* Date: 2026-07-29
* Description: Common embedded development packages and vendor-specific imports.
*/
{ config, pkgs, ... }:
{
  imports = [
    ./embedded
  ];

  environment.systemPackages = with pkgs; [
    openocd
    probe-rs-tools
    dfu-util
    libusb1

    minicom
    picocom
    screen
    usbutils

    platformio
    openocd
  ];
}
