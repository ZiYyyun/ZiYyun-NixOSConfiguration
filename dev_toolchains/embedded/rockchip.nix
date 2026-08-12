{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedLinuxCrossShell = import ../libs/embedded-linux-cross-shell.nix;
in
mkEmbeddedLinuxCrossShell {
  inherit pkgs;
  name = "rockchip";
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
  arch = "arm64";
  packages = embeddedPackages.rockchip;
  tools = [ "aarch64 cross gcc" "dtc" "ubootTools" "rkdeveloptool" "rkflashtool" "rkbin" "rkboot" ];
  versionCommands = [
    { name = "cross gcc"; bin = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}gcc"; command = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}gcc --version"; }
    { name = "dtc"; bin = "dtc"; command = "dtc --version"; }
    { name = "rkdeveloptool"; bin = "rkdeveloptool"; command = "rkdeveloptool -v"; }
  ];
  message = "Rockchip ARM64 Linux cross environment with rkdeveloptool, rkflashtool, rkbin and rkboot.";
}
