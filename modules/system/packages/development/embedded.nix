/**
 * File: embedded.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Common embedded development packages and vendor-specific imports.
 */
{ config, pkgs, ... }:
{
  imports = [
    ./embedded/espressif.nix
    ./embedded/nordic.nix
    ./embedded/stm.nix
  ];

  environment.systemPackages = with pkgs; [
    cmake
    gcc
    gdb
    gnumake
    ninja
    pkg-config

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
