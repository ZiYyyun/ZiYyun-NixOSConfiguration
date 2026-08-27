/**
 * File: nvidia.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: ThinkPad P14s Gen5 Intel 独显（NVIDIA PRIME）补全配置。
 *
 * nixos-hardware 官方 p14s-intel-gen5 模块已配置：i915 核显 + NVIDIA
 * PRIME offload（nvidia-offload 命令）+ 开源内核模块（turing）。
 * 这里补全官方没有的：
 *   - modesetting：NVIDIA 内核模式设置（Wayland 必需）
 *   - powerManagement：动态电源管理 / RTD3 深度休眠独显（省电）
 *   - nvidiaSettings：nvidia-settings 图形配置工具
 *
 * 注意：powerManagement.finegrained 为实验性 RTD3，若挂起/唤醒异常可移除。
 */
{ ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
  };
}
