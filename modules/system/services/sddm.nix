/**
 * File: sddm.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Shared SDDM appearance settings.
 */
{ lib, pkgs, ... }:
let
  # embeddedTheme 可选内置主题；动态壁纸的有：hyprland_kath(mp4)、
  # jake_the_dog(mp4)、pixel_sakura(gif)。
  astronautTheme = (pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
  }).overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      if [ -d "$out/share/sddm/themes/sddm-astronaut-theme/Fonts" ]; then
        mkdir -p "$out/share/fonts"
        cp -r "$out/share/sddm/themes/sddm-astronaut-theme/Fonts/"* "$out/share/fonts/"
      fi
    '';
  });
in
{
  environment.systemPackages = [
    astronautTheme
    pkgs.kdePackages.qtmultimedia
  ];
  fonts.packages = [ astronautTheme ];

  services.displayManager.sddm = {
    package = lib.mkDefault pkgs.kdePackages.sddm;
    theme = "${astronautTheme}/share/sddm/themes/sddm-astronaut-theme";
    extraPackages = [
      astronautTheme
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtvirtualkeyboard
    ];
    settings.Users = {
      RememberLastUser = true;
      RememberLastSession = true;
    };
  };
}
