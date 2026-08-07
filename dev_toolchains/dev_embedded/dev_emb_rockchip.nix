{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  mkDevEmbLinuxCrossShell = import ../libs/libs_emb_linux_cross_shell.nix;
in
mkDevEmbLinuxCrossShell {
  inherit pkgs;
  name = "rockchip";
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
  arch = "arm64";
  packages = devEmbPackages.rockchip;
  message = "Rockchip ARM64 Linux cross environment with rkdeveloptool, rkflashtool, rkbin and rkboot.";
}
