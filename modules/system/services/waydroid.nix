/**
 * File: waydroid.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: WayDroid (Android in a Wayland container) enablement.
 *
 * NixOS only declares the runtime here. The ~1.4 GB Android system image is
 * downloaded separately by `shells/waydroid-init.sh` and written to
 * /var/lib/waydroid/images/, because it does not belong in the Nix store.
 *
 * Kernel prerequisites (ANDROID_BINDER_IPC, ANDROID_BINDERFS, MEMFD_CREATE,
 * PSI) are already enabled in the default nixpkgs kernel, so no custom kernel
 * is required. The module asserts them at eval time.
 */
{ ... }:
{
  virtualisation.waydroid.enable = true;
}
