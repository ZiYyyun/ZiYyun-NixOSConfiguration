/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Shared service module entrypoint.
 */
{ ... }:
{
  imports = [
    ./dbus.nix
    ./edge.nix
    ./input-method.nix
    ./linyaps.nix
    ./sddm.nix
    ./auto-update.nix
  ];
}
