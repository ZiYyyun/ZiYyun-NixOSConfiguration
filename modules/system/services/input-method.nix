/**
 * File: input-method.nix
 * Author: ziyun
 * Date: 2026-07-30
 * Description: Chinese input method configuration based on Fcitx5 and Rime.
 */
{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-chinese-addons
    ];
  };

  environment.systemPackages = with pkgs; [
    kdePackages.fcitx5-configtool
  ];

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
