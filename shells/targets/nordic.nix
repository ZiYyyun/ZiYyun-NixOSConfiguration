{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkMcuShell = import ../lib/mk-mcu-shell.nix;
in
mkMcuShell {
  inherit pkgs;
  name = "nordic";
  packages = packageGroups.nordic;
  env = {
    CHIP_VENDOR = "Nordic";
  };
  message = "Nordic nRF shell without nrf-command-line-tools, avoiding the Qt4/J-Link GUI dependency.";
}
