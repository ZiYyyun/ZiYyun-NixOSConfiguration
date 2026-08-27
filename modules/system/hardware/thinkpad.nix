/**
 * File: thinkpad.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: ThinkPad 通用硬件优化（三台 ThinkPad 共用）。
 *
 * nixos-hardware 官方 thinkpad 模块已覆盖：trackpoint/小红点滚轮模拟、
 * TLP 电源管理（默认启用）、Intel GPU VAAPI。这里补充官方没有的：
 *   - 键盘背光：普通用户可直接调节（udev uaccess + brightnessctl）
 *   - 触摸板：tap 点击、自然滚动、打字时禁用
 *   - Intel DPTF 热管理（thermald）
 *
 * Fn 功能键说明：ThinkPad 的 FnLock（Fn+Esc）由 BIOS/EC 控制，
 * NixOS 无法在软件层切换；媒体键（亮度/音量/背光）由 thinkpad_acpi
 * 驱动自动上报，无需额外配置。
 */
{ pkgs, ... }:
{
  # ---- 键盘背光 ----
  # brightnessctl 用于命令行调节背光（/sys/class/leds/tpacpi::kbd_backlight）。
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # 授予登录用户（uaccess ACL）读写键盘背光 sysfs，无需 sudo。
  services.udev.extraRules = ''
    SUBSYSTEM=="leds", KERNEL=="tpacpi::kbd_backlight", TAG+="uaccess"
  '';

  # ---- 触摸板增强（Xorg 会话生效；Wayland 下由 KDE/GNOME 各自接管）----
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };

  # ---- Intel DPTF 自适应热管理 ----
  services.thermald.enable = true;
}
