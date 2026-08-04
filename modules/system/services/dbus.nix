/**
 * File: dbus.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: D-Bus implementation selection.
 */
{ ... }:
{
  # dbus-broker can fail to reload during live system switches while desktop
  # user sessions are active. Use the reference daemon for predictable rebuilds.
  services.dbus.implementation = "dbus";
}
