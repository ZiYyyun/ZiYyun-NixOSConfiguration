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
  tools = [ "nrfutil" "probe-rs-tools" "openocd" "dfu-util" "serial tools" ];
  versionCommands = [
    { name = "nrfutil"; bin = "nrfutil"; command = "nrfutil --version"; }
    { name = "probe-rs"; bin = "probe-rs"; command = "probe-rs --version"; }
    { name = "openocd"; bin = "openocd"; command = "openocd --version"; }
  ];
  message = "Nordic nRF shell without nrf-command-line-tools, avoiding the Qt4/J-Link GUI dependency.";
}
