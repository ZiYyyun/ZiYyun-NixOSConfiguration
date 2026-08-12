{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  mkDevEmbLinuxCrossShell = import ../libs/libs_emb_linux_cross_shell.nix;
in
mkDevEmbLinuxCrossShell {
  inherit pkgs;
  name = "arm32";
  crossPkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
  arch = "arm";
  packages = devEmbPackages.linuxSocCommon ++ devEmbPackages.nxpImx;
  tools = [ "armv7l cross gcc" "gdb" "dtc" "ubootTools" "NXP uuu" "filesystem image tools" ];
  versionCommands = [
    { name = "cross gcc"; bin = "${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.targetPrefix}gcc"; command = "${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.targetPrefix}gcc --version"; }
    { name = "dtc"; bin = "dtc"; command = "dtc --version"; }
    { name = "uuu"; bin = "uuu"; command = "uuu -V"; }
  ];
  message = "Generic ARMv7 Linux cross environment. Suitable for i.MX6ULL and many 32-bit ARM SoCs, with NXP UUU.";
}
