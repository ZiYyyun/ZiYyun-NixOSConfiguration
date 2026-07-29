/**
 * File: nordic.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Nordic nRF development packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nrf-command-line-tools
    nrfconnect
    nrf5-sdk
    nrf-udev
    nrfutil
  ];
}
