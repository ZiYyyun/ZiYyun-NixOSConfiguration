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
 *   - 翻转  360° 翻转 + Koga HID 触控屏/触控笔
 *   - 传感  Intel Sensor Collection（8087:0ac2，经 ISH/IIO 上报姿态）
 *   - 指纹  Goodix 27c6:5812（当前 libfprint 不支持）
 *
 * nixos-hardware 说明：官方没有 Xiaomi Book Air / Alder Lake 机型模块（xiaomi 下只有
 * redmibook 15 2021 / 16 2024，均非本机平台）。host 里已引 nixos-hardware 的
 * common-cpu-intel + common-pc-laptop + common-pc-ssd（Intel 微码、i915/VAAPI 基础、
 * 笔记本基础），本模块只补官方没有的本机细节。
 */
{
  pkgs,
  lib,
  ...
}:
{
  # ---- 可再分发的固件（AX211/iwlwifi、Intel CPU 微码）----
  # common-cpu-intel 已默认 `updateMicrocode = mkDefault enabled`，这里开红线固件即可。
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # AX211 的 Wi-Fi 由 iwlwifi 自动加载；蓝牙部分需要显式启用 BlueZ。
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # 两个 USB-C 接口支持 Thunderbolt 4。bolt 负责设备授权，Plasma 会同时
  # 安装相应的管理界面。
  services.hardware.bolt.enable = true;

  # ---- Alder Lake 12 代核显 VAAPI ----
  # common-cpu-intel 已带 i915 基础驱动与 intel-gpu 包；12 代（Gen12）核显官方推荐
  # intel-media-driver 作 VAAPI 后端（硬解 HEVC/AV1）。选项由 nixos-hardware 提供。
  hardware.intelgpu.vaapiDriver = lib.mkDefault "intel-media-driver";

  # ---- 电源 / 热管理 ----
  # Plasma 默认使用 power-profiles-daemon；明确关闭与它互斥的 TLP，避免
  # 两边的默认值随上游变化后触发 NixOS assertion。
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
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

  # ---- 翻转本：触控、触控笔与姿态传感器 ----
  # 将 HID over I2C、Intel LPSS/ISH 标为 initrd 可用；正常情况下仍由设备
  # modalias 按需加载。KDE 直接消费 iio-sensor-proxy，Niri 还需要 iio-niri
  # 把姿态变化转换为 output transform。
  boot.initrd.availableKernelModules = [
    "i2c_hid_acpi"
    "intel_lpss_pci"
    "intel_ish_ipc"
    "hid-sensor-hub"
  ];
  hardware.sensor.iio.enable = true;
  services.iio-niri.enable = true;

  # Goodix USB 27c6:5812 is not supported by upstream libfprint as of this
  # pinned release. Do not enable fprintd until the device ID is supported.
}
