/**
 * File: qoder-cli.nix
 * Author: ziyun
 * Date: 2026-08-25
 * Description: Qoder CN CLI 的 systemd 用户服务（remote-control 守护进程）。
 *
 * Qoder CN CLI 本体是交互式 TUI（qodercli / qoderclicn），本身不需要开机
 * 自启；它唯一的常驻组件是 `qoderclicn remote-control` 守护进程（远程控制/
 * 后台 Agent 任务），本模块在用户登录后自动拉起它。
 *
 * 前提：先 `qodercli login` 登录一次（或设 QODERCN_DEVICE_TOKEN），否则
 * 守护进程会报 "Not logged in" 退出；Restart=on-failure 会在登录完成后
 * 自动重试拉起。
 */
{ config, lib, pkgs, customPackages, ... }:
{
  # 注意：home-manager 的 systemd.user.services 是分节自由格式
  # （Unit/Service/Install），与 NixOS 的 serviceConfig/after 便捷写法不同。
  systemd.user.services.qoder-remote-control = {
    Unit = {
      Description = "Qoder CLI CN remote-control daemon";
      After = [ "default.target" ];
    };
    Service = {
      ExecStart = "${customPackages.qoder-cli-cn}/bin/qoderclicn remote-control";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
