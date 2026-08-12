/**
 * File: embedded-packages.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Reusable package groups for Embedded Toolchains.
 */
{ pkgs }:
rec {
  buildCore = with pkgs; [
    cmake
    gnumake
    ninja
    pkg-config
    git
    python3
    file
    which
  ];

  firmwareTools = with pkgs; [
    dtc
    ubootTools
    mtdutils
    parted
    dosfstools
    e2fsprogs
    mtools
  ];

  debugAndFlash = with pkgs; [
    openocd
    probe-rs-tools
    dfu-util
    libusb1
  ];

  serialTools = with pkgs; [
    minicom
    picocom
    screen
    usbutils
  ];

  cortexM = with pkgs; [
    pkgs.pkgsCross.arm-embedded.stdenv.cc
    stlink
    stm32flash
  ];

  stm = buildCore ++ debugAndFlash ++ serialTools ++ cortexM;

  esp = buildCore ++ serialTools ++ debugAndFlash ++ (with pkgs; [
    esptool
    espflash
    platformio
  ]);

  nordic = buildCore ++ debugAndFlash ++ serialTools ++ (with pkgs; [
    nrfutil
  ]);

  segger = buildCore ++ serialTools ++ (with pkgs; [
    steam-run
  ]);

  linuxSocCommon = firmwareTools ++ (with pkgs; [
    bc
    bison
    flex
    openssl
    ncurses
    rsync
    cpio
    file
  ]);

  nxpImx = with pkgs; [
    uuu
  ];

  allwinner = linuxSocCommon ++ (with pkgs; [
    sunxi-tools
  ]);

  rockchip = linuxSocCommon ++ (with pkgs; [
    rkdeveloptool
    rkflashtool
    rkbin
    rkboot
  ]);

  c = linuxSocCommon ++ (with pkgs; [
      clang
      paho-mqtt-c
      libclang
      glibc
  ]);
}
