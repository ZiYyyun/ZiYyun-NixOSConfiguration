{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedMcuShell = import ../libs/embedded-mcu-shell.nix;
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "nordic";
  packages = embeddedPackages.nordic;
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
