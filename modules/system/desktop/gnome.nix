/**
 * File: gnome.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: GNOME desktop enablement, session configuration, and desktop-specific packages.
 */
{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME 专用包（GNOME 应用在 pkgs 顶层，如 pkgs.snapshot）。
  environment.systemPackages = with pkgs; [
    snapshot  # 截图工具（原 flatpak org.gnome.Snapshot，已改 Nix 包）
  ];
}
