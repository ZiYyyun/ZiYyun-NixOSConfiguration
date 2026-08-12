{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedLinuxCrossShell = import ../libs/embedded-linux-cross-shell.nix;
in
mkEmbeddedLinuxCrossShell {
  inherit pkgs;
  name = "allwinner";
  crossPkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
  arch = "arm";
  packages = embeddedPackages.allwinner;
  tools = [ "armv7l cross gcc" "dtc" "ubootTools" "sunxi-tools" "mtdutils" "filesystem image tools" ];
  versionCommands = [
    { name = "cross gcc"; bin = "${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.targetPrefix}gcc"; command = "${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.targetPrefix}gcc --version"; }
    { name = "dtc"; bin = "dtc"; command = "dtc --version"; }
    { name = "sunxi-fel"; bin = "sunxi-fel"; command = "sunxi-fel version"; }
  ];
  message = "Allwinner ARMv7 Linux environment with sunxi-tools, dtc and image utilities.";
}
