/**
 * File: sddm.nix
 * Author: ziyun
 * Date: 2026-08-04
 * Description: Shared SDDM appearance settings.
 */
{ pkgs, ... }:
let
  astronautTheme = (pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
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
    package = pkgs.kdePackages.sddm;
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
