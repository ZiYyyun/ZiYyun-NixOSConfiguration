/**
 * File: xiaomi-book-air13.nix
 * Author: ziyun
 * Date: 2026-09-06
 * Description: 小米翻转本 Xiaomi Book Air 13（2022，12代 Intel Alder Lake）硬件适配。
 *
 * 机型硬件规格（NotebookCheck 评测 / 拆机确认）：
 *   - CPU   i5-1230U / i7-1250U（Alder Lake）
 *   - GPU   集成 Xe 核显（UHD，12 代用 intel-media-driver 走 VAAPI）
 *   - 无线  Intel Wi-Fi 6E AX211（iwlwifi）
 *   - 屏幕  三星 E4 OLED 2880×1800 60Hz（可变刷新由面板/OS 控制，此处仅背光）
 *   - 内存  板载 LPDDR5-5200（不可换）
 *   - 硬盘  铠侠（KIOXIA）NVMe PCIe 4.0
 *   - 翻转  360° 翻转 + 触控屏/触控笔（靠 iio 加速度计旋转 + 触屏实现平板模式）
 *
 * nixos-hardware 说明：官方没有 Xiaomi Book Air / Alder Lake 机型模块（xiaomi 下只有
 * redmibook 15 2021 / 16 2024，均非本机平台）。host 里已引 nixos-hardware 的
 * common-cpu-intel + common-pc-laptop + common-pc-ssd（Intel 微码、i915/VAAPI 基础、
 * TLP 电源），本模块只补官方没有的本机细节。
 *
 * 装机后校准项（写注释处）：键盘背光节点名、OLED 背光节点名都需要实机
 * `ls /sys/class/leds/` 核对后再收紧，首版用通配以能跑通为准。
 */
{
  pkgs,
  config,
  lib,
  ...
}:
{
  # ---- 可再分发的固件（AX211/iwlwifi、Intel CPU 微码）----
  # common-cpu-intel 已默认 `updateMicrocode = mkDefault enabled`，这里开红线固件即可。
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # ---- Alder Lake 12 代核显 VAAPI ----
  # common-cpu-intel 已带 i915 基础驱动与 intel-gpu 包；12 代（Gen12）核显官方推荐
  # intel-media-driver 作 VAAPI 后端（硬解 HEVC/AV1）。选项由 nixos-hardware 提供。
  hardware.intelgpu.vaapiDriver = lib.mkDefault "intel-media-driver";

  # ---- 电源 / 热管理 ----
  # TLP 由 common-pc-laptop 默认启用；Alder Lake 低功耗 U 系再补 thermald 温度控制。
  services.thermald.enable = true;

  # ---- 屏幕背光（OLED）----
  # brightnessctl：命令行/快捷键调亮度（/sys/class/backlight/*）。
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # ---- 键盘背光 ----
  # 通配匹配小米的键盘背光 LED 节点（实测节点名待装机后 ls /sys/class/leds/ 收紧）。
  # 授 uaccess 让普通用户可调，无需 sudo。
  services.udev.extraRules = ''
    SUBSYSTEM=="leds", KERNEL=="*_kbd_backlight", TAG+="uaccess"
  '';

  # ---- 触摸板 ----
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };

  # ---- 翻转本：旋转传感器 + 平板模式 ----
  # iio 加速度计经 iio-sensor-proxy 供桌面（KDE 自动旋转、平板模式禁用触摸板）。
  # 触控屏/触控笔由内核 i2c-hid 默认驱动，无需额外配置。
  hardware.sensor.iio.enable = true;
}