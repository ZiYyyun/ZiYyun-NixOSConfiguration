{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  mkDevEmbMcuShell = import ../libs/libs_emb_mcu_shell.nix;
in
mkDevEmbMcuShell {
  inherit pkgs;
  name = "esp";
  packages = devEmbPackages.esp;
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
