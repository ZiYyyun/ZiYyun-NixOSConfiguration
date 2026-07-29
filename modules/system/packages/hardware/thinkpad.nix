/**
 * File: thinkpad.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: ThinkPad hardware support packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tpacpi-bat
    hdapsd
  ];
}
