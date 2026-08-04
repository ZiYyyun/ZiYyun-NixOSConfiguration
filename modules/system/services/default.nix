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
    ./input-method.nix
    ./sddm.nix
  ];
}
