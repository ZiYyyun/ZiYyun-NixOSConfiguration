/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-09-06
 * Description: Host profile for Xiaomi Book Air 13 (2022, Intel Alder Lake 翻转本).
 *
 * nixos-hardware 说明：官方无本机机型（xiaomi 下仅 redmibook 15/16，均非 Alder Lake），
 * 所以改用其通用栈：common-cpu-intel（Intel 微码 + i915/VAAPI）+ common-pc-laptop
 * + common-pc-ssd。机型专属细节放 modules/system/hardware/xiaomi-book-air13.nix。
 * 桌面走 KDE + niri + noctalia（与 ThinkPad-P14s 一致）。
 */
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../common/hardware-configuration.nix
    ../../common/boot/uefi.nix
    ./hardware-configuration.nix
    ../../../modules/system/desktop/kde.nix
    ../../../modules/system/desktop/niri.nix
    ../../../modules/system/desktop/noctalia.nix
    ../../../modules/system/hardware/xiaomi-book-air13.nix
    ../../../modules/system/services/flatpak.nix
  ];
}
