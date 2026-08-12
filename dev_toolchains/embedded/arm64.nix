{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedLinuxCrossShell = import ../libs/embedded-linux-cross-shell.nix;
in
mkEmbeddedLinuxCrossShell {
  inherit pkgs;
  name = "arm64";
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;
  arch = "arm64";
  packages = embeddedPackages.linuxSocCommon;
  tools = [ "aarch64 cross gcc" "gdb" "dtc" "ubootTools" "filesystem image tools" ];
  versionCommands = [
    { name = "cross gcc"; bin = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}gcc"; command = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}gcc --version"; }
    { name = "dtc"; bin = "dtc"; command = "dtc --version"; }
  ];
  message = "Generic ARM64 Linux cross environment.";
}
