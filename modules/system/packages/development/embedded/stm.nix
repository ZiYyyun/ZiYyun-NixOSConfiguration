/**
 * File: stm.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: STM32 development packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    stm32flash
    stlink
  ];
}