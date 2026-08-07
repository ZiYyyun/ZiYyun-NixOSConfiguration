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
  message = "Espressif shell: esptool, espflash, PlatformIO, serial tools and probe-rs.";
}
