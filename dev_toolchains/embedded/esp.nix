{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedMcuShell = import ../libs/embedded-mcu-shell.nix;
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "esp";
  packages = embeddedPackages.esp;
  env = {
    CHIP_VENDOR = "Espressif";
  };
  tools = [ "esptool" "espflash" "platformio" "openocd" "probe-rs-tools" "serial tools" ];
  versionCommands = [
    { name = "esptool"; bin = "esptool"; command = "esptool version"; }
    { name = "espflash"; bin = "espflash"; command = "espflash --version"; }
    { name = "platformio"; bin = "pio"; command = "pio --version"; }
    { name = "openocd"; bin = "openocd"; command = "openocd --version"; }
  ];
  message = "Espressif shell: esptool, espflash, PlatformIO, serial tools and probe-rs.";
}
