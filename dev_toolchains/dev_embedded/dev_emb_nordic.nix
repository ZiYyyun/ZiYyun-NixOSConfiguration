{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  mkDevEmbMcuShell = import ../libs/libs_emb_mcu_shell.nix;
in
mkDevEmbMcuShell {
  inherit pkgs;
  name = "nordic";
  packages = devEmbPackages.nordic;
  env = {
    CHIP_VENDOR = "Nordic";
  };
  message = "Nordic nRF shell without nrf-command-line-tools, avoiding the Qt4/J-Link GUI dependency.";
}
