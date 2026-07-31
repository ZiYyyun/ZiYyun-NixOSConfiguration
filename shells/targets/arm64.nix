{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkLinuxCrossShell = import ../lib/mk-linux-cross-shell.nix;
in
mkLinuxCrossShell {
  inherit pkgs;
  name = "arm64";
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
  arch = "arm64";
  packages = packageGroups.linuxSocCommon;
  message = "Generic ARM64 Linux cross environment.";
}
