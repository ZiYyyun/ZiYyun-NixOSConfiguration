/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Root Home Manager module for ziyun.
 */
{ ... }:
{
  imports = [
    ./accounts
    ./programs
    ./config-files
  ];

  home.stateVersion = "26.05";
}
