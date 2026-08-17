/**
 * File: fprintd.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: Fingerprint reader support (fprintd + libfprint).
 *
 * ThinkPad P14s Gen 5 has a Synaptics 06cb:00f9 reader, which is supported
 * by libfprint 1.94.10 (id 0x00F9 in drivers/synaptics/synaptics.c), the
 * version pinned in nixos-26.05. nixos-hardware deliberately leaves
 * `services.fprintd.enable` commented out, so each machine opts in here.
 *
 * After rebuild, enroll a finger with:
 *   fprintd-enroll
 * and verify with:
 *   fprintd-list <user>
 */
{ ... }:
{
  services.fprintd.enable = true;
  # TODO: Touch OEM Driver (TOD) only needed for readers that require a
  # proprietary driver package (e.g. some Goodix). Synaptics 06cb:00f9 works
  # with the open libfprint driver, so TOD stays disabled.
  # services.fprintd.tod.enable = false;
}
