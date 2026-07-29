/**
 * File: espressif.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Espressif ESP development packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    esphome
    esptool
    espflash
  ];
}
