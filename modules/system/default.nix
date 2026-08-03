/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Shared system module entrypoint.
 */
{ ... }:
{
  imports = [
    ./packages
    ./services
  ];
}
