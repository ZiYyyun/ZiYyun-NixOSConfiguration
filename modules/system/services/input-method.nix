/**
 * File: input-method.nix
 * Author: ziyun
 * Date: 2026-07-30
 * Description: Chinese input method configuration based on Fcitx5 and Rime.
 *
 * Wayland note: environment.sessionVariables alone does not reach GUI apps
 * launched through the systemd user instance on KDE Plasma 6 Wayland.
 * Use systemd.user.environmentFile to inject IM environment variables for
 * systemd user services, start fcitx5 as a user service.
 */
{ pkgs, lib, ... }:

let
  imEnv = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
  };

  # 生成环境变量文件，供给 systemd user 全局加载
  imEnvFile = pkgs.writeText "fcitx5-im-env.conf"
    (lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") imEnv));
in
{
  # ========== 输入法核心配置 ==========
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    # fcitx5.addons —— fcitx5 内部用的输入法引擎和插件
    fcitx5.addons = with pkgs; [
      fcitx5-rime              # Rime 输入法引擎
      # fcitx5-chinese-addons    # 拼音等中文输入法
      qt6Packages.fcitx5-chinese-addons  # Qt6 支持的中文输入法前端
    ];
  };

  # ========== 系统包（顶层选项，和 i18n.inputMethod 同级！）==========
  environment.systemPackages = with pkgs; [
    kdePackages.fcitx5-configtool   # 图形配置工具（kde 版本）
    fcitx5-gtk                      # GTK 应用的输入法支持
    kdePackages.fcitx5-qt           # Qt 应用的输入法支持
  ];

  # ========== 环境变量（顶层选项！）==========
  environment.sessionVariables = imEnv;

  # ========== systemd 用户实例配置（顶层选项！）==========
  # 让所有 systemd user 单元继承输入法环境变量（解决 KDE Wayland 问题）
  systemd.user.extraConfig = ''
    EnvironmentFile=${imEnvFile}
  '';

  # Keep fcitx5 running for the whole graphical session.
  systemd.user.services.fcitx5 = {
    description = "Fcitx5 Input Method Framework";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.fcitx5}/bin/fcitx5 --replace";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}