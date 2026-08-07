/**
* File: embedded.nix
* Author: ziyun
* Date: 2026-08-07
* Description: Common embedded development packages and vendor-specific imports.
*/
{ config, pkgs, ... }:
{


  environment.systemPackages = with pkgs; [
    clang
    paho-mqtt-c
    libclang
  ];
}
