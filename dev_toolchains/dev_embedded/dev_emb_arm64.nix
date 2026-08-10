{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  mkDevEmbLinuxCrossShell = import ../libs/libs_emb_linux_cross_shell.nix;
in
mkDevEmbLinuxCrossShell {
  inherit pkgs;
  name = "arm64";
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
  arch = "arm64";
  packages = devEmbPackages.linuxSocCommon;
  message = "Generic ARM64 Linux cross environment.";
}
