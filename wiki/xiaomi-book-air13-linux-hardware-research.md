# Xiaomi Book Air 13: Linux hardware research

更新时间：2026-09-15

这份记录只收录可以由公开源码或包索引复核的结果。设备仍需在本机上做最终验证，尤其是 ACPI 拓扑、MIPI lane 数和固件版本。

## 摄像头：HI847 / IPU6EP

### 已确认的可用代码

- Linux 主线已有 [HI847 V4L2 传感器驱动](https://github.com/torvalds/linux/blob/master/drivers/media/i2c/hi847.c)。
- Intel 的 [`ipu6-drivers`](https://github.com/intel/ipu6-drivers) 仓库的 `v6.8` 至 `v7.0` 构建补丁包含 `VIDEO_HI847` 的 Kconfig/Makefile 配置。
- AUR 有 `intel-ipu6-dkms-git`、`intel-ipu6ep-camera-hal-git`、`intel-ipu6-camera-bin` 和 `icamerasrc-git`，但这些包分别对应 Intel 的内核驱动、HAL、闭源二进制和 GStreamer 适配层，并不添加 HI847 的 HAL profile。

### 当前阻塞点

Intel [`ipu6-camera-hal`](https://github.com/intel/ipu6-camera-hal) 当前源码树中没有 `HI847` 或 `HYV0847` 字符串；`ipu6-camera-bins` 也没有公开的对应 profile/tuning 数据。换句话说，移植内核驱动是可行的，但仅启用 `VIDEO_HI847` 仍不能让 IPU6EP 用户空间持续出帧。

### NixOS 移植结论

暂不把 `hardware.ipu6.enable` 改回 `true`，也不伪造 relay 摄像头。下一步若要继续，顺序应是：

1. 用本机 `media-ctl -p`、`dmesg` 和 ACPI/I2C 信息确认 HI847 的实际 module ID、lane 数、link frequency 和时钟。
2. 将 Intel `ipu6-drivers` 的 HI847 内核补丁以 Nix kernel patch 方式做实验构建。
3. 只有拿到能匹配该 module ID 的 AIQ/tuning/graph 数据后，再为 `ipu6-camera-hal` 增加 profile，并用 `v4l2-ctl --stream-mmap` 验证连续帧。

## 指纹：Goodix `27c6:5812`

libfprint 的开发版公开支持表列出了多个 Goodix MOC ID（例如 `27c6:5840`、`60c2`、`609x`、`63xx`、`65xx`），但没有 `27c6:5812`：

- [libfprint supported devices](https://fprint.freedesktop.org/supported-devices.html)
- [libfprint GitLab](https://gitlab.freedesktop.org/libfprint/libfprint)

AUR 中能找到的 Goodix 分支也针对其他 ID（`521d`、`533c`、`5335/5385/5395`、`55a2`、`60c2`、`55x4`、`5110`、`52xd`），没有 `5812` 的驱动或 TOD 包。不能通过给现有驱动追加 USB ID 来解决：MOC 设备的协议/固件匹配是按芯片系列来的。

### NixOS 移植结论

当前没有可直接移植的开源或发行版包。需要先取得厂商 Linux TOD/固件，或对 Windows 驱动和 USB 协议做逆向；在此之前保持 `fprintd` 未启用是正确行为。

## 键盘背光：`redmi_wmi`

Linux 主线的 [`redmi-wmi.c`](https://github.com/torvalds/linux/blob/master/drivers/platform/x86/redmi-wmi.c) 将背光 Fn 事件映射为 `KEY_KBDILLUMTOGGLE`，并明确注释事件状态为 Off/Auto/Low/High。这个驱动只解析 WMI 输入事件：没有 LED class、亮度读写或 EC/WMI 设置方法。

因此“能收到 Fn 事件”和“系统有 `/sys/class/leds/*kbd*` 可控制”是两件事。当前机器没有 LED 节点时，继续添加 udev 规则不会产生控制能力。

### NixOS 移植结论

先在实体机上确认：

```text
libinput debug-events
ls -l /sys/class/leds /sys/class/backlight
evtest
```

若 Fn 键只产生 `KEY_KBDILLUMTOGGLE` 而没有 LED 节点，需要从 ACPI/WMI 方法或 EC 寄存器入手；这不是一个可以从 AUR/Deb/RPM 直接安装的用户空间包。若固件根本没有背光硬件/方法，则 Linux 无法凭软件补出来。

## 总结

| 硬件 | Linux 公开代码 | 现成包是否足够 | 当前动作 |
| --- | --- | --- | --- |
| HI847 摄像头 | 内核驱动有；IPU6 HAL profile 无 | 否 | 先采集本机拓扑，再做 kernel patch；等待/寻找 AIQ 数据 |
| Goodix `27c6:5812` | 官方支持表无；AUR 无该 ID | 否 | 不启用 fprintd，寻找厂商 TOD 或进行协议逆向 |
| 键盘背光 | `redmi_wmi` 只提供按键事件 | 否 | 检查实体背光与 EC/WMI；不添加伪造 udev 规则 |

