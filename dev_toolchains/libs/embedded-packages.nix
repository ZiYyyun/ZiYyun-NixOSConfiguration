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

  # 合宙 LuatOS（CSDK 工具链 + 烧录/调试/测试工具）。
  # luatool 与 luatos-utils 来自 packages/custom/luatos-tools，由
  # dev_toolchains/embedded/luatos.nix 额外追加。
  luatos = buildCore ++ serialTools ++ (with pkgs; [
    pkgsCross.riscv64-embedded.stdenv.cc   # riscv64-none-elf (Air101/Air103 C906)
    pkgsCross.riscv32-embedded.stdenv.cc   # riscv32-none-elf (ESP32C3 等)
    pkgsCross.arm-embedded.stdenv.cc       # arm-none-eabi (Air32F103/STM32)
    esptool                               # ESP32 系烧录
    gpsbabel                              # GPS 纠偏/转换（通用）
  ]);
}
