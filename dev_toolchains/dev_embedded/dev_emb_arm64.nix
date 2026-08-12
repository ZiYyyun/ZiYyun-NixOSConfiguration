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
  tools = [ "aarch64 cross gcc" "gdb" "dtc" "ubootTools" "filesystem image tools" ];
  versionCommands = [
    { name = "cross gcc"; bin = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}gcc"; command = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}gcc --version"; }
    { name = "dtc"; bin = "dtc"; command = "dtc --version"; }
  ];
  message = "Generic ARM64 Linux cross environment.";
}
