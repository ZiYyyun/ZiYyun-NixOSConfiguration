{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkLinuxCrossShell = import ../lib/mk-linux-cross-shell.nix;
in
mkLinuxCrossShell {
  inherit pkgs;
  name = "allwinner";
  crossPkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
  arch = "arm";
  packages = packageGroups.allwinner;
  message = "Allwinner ARMv7 Linux environment with sunxi-tools, dtc and image utilities.";
}
