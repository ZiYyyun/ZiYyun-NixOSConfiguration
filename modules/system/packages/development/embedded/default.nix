/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Optional vendor-specific embedded system package entrypoint.
 */
{ ... }:
{
  # Intentionally empty. Vendor-specific SDK/tooling belongs in devShells by
  # default, so the global system profile stays small and avoids stale GUI
  # dependencies such as Nordic's Qt4 path.
  imports = [ ];
}
