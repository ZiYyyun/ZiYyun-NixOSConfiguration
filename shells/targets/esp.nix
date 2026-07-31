{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkMcuShell = import ../lib/mk-mcu-shell.nix;
in
mkMcuShell {
  inherit pkgs;
  name = "esp";
  packages = packageGroups.esp;
  env = {
    CHIP_VENDOR = "Espressif";
  };
  message = "Espressif shell: esptool, espflash, PlatformIO, serial tools and probe-rs.";
}
