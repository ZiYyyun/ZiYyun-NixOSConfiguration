/**
 * File: thinkpad.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: ThinkPad-specific system packages.
 */
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tpacpi-bat
    hdapsd
  ];
}
