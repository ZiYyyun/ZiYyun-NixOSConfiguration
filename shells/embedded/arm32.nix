{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkLinuxCrossShell = import ../lib/mk-linux-cross-shell.nix;
in
mkLinuxCrossShell {
  inherit pkgs;
  name = "arm32";
  crossPkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
  arch = "arm";
  packages = packageGroups.linuxSocCommon ++ packageGroups.nxpImx;
  message = "Generic ARMv7 Linux cross environment. Suitable for i.MX6ULL and many 32-bit ARM SoCs, with NXP UUU.";
}
