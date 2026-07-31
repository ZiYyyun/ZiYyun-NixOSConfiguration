{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkLinuxCrossShell = import ../lib/mk-linux-cross-shell.nix;
in
mkLinuxCrossShell {
  inherit pkgs;
  name = "rockchip";
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
  arch = "arm64";
  packages = packageGroups.rockchip;
  message = "Rockchip ARM64 Linux cross environment with rkdeveloptool, rkflashtool, rkbin and rkboot.";
}
