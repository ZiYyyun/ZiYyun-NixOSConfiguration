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
 * PAM / login integration is automatic: `security.pam.services.*.fprintAuth`
 * defaults to `services.fprintd.enable`, so enabling fprintd adds the
 * fingerprint module to every PAM service unless explicitly disabled:
 *   - login / sddm (sddm substacks login) : TTY and SDDM login
 *   - kde-fingerprint                    : KDE Plasma lock screen
 *                                          (kscreenlocker uses
 *                                          KSCREENLOCKER_PAM_FINGERPRINT_SERVICE
 *                                          = "kde-fingerprint"; the plain
 *                                          `kde` service stays password-only)
 *   - swaylock                           : Niri lock screen
 *   - sudo / su                          : privilege escalation
 * All use `sufficient` control, so a failed scan falls back to password.
 *
 * Commands after rebuild:
 *   fprintd-enroll    # enroll a finger (run 3 scans)
 *   fprintd-list ziyun
 */
{ ... }:
{
  services.fprintd.enable = true;
  # TODO: Touch OEM Driver (TOD) only needed for readers that require a
  # proprietary driver package (e.g. some Goodix). Synaptics 06cb:00f9 works
  # with the open libfprint driver, so TOD stays disabled.
  # services.fprintd.tod.enable = false;
}
