/**
 * File: thinkpad-legacy.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: 老款 ThinkPad（X230/X270）专用优化。
 *
 * nixos-hardware 官方没有风扇控制模块；老机型 EC 控温偏保守，
 * 用 thinkfan 接管风扇。启用时模块自动加载
 * `thinkpad_acpi experimental=1 fan_control=1`。
 *
 * acpi_osi=Linux：老 ThinkPad 常见 ACPI 兼容参数，修复部分
 * Fn 组合键 / 亮度 / 电池事件异常。
 */
{ ... }:
{
  # ---- 风扇控制（thinkfan，默认读取 /proc/acpi/ibm/thermal + /proc/acpi/ibm/fan）----
  services.thinkfan.enable = true;

  # ---- 老机型 ACPI 兼容（Fn 组合键 / 亮度等）----
  boot.kernelParams = [
    "acpi_osi=Linux"
  ];
}
