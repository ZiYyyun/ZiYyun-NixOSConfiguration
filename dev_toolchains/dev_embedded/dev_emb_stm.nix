{ pkgs, ... }:
let
  devEmbPackages = import ../libs/libs_emb_packages.nix { inherit pkgs; };
  mkDevEmbMcuShell = import ../libs/libs_emb_mcu_shell.nix;
in
mkDevEmbMcuShell {
  inherit pkgs;
  name = "stm";
  packages = devEmbPackages.stm;
  env = {
    CHIP_VENDOR = "STMicroelectronics";
    TARGET_ARCH = "arm-none-eabi";
  };
  message = "STM32 environment: arm-none-eabi toolchain, OpenOCD, ST-Link, stm32flash.";
}
