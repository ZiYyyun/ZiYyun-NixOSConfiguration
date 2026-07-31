{ pkgs, ... }:
let
  packageGroups = import ../lib/packages.nix { inherit pkgs; };
  mkMcuShell = import ../lib/mk-mcu-shell.nix;
in
mkMcuShell {
  inherit pkgs;
  name = "stm";
  packages = packageGroups.stm;
  env = {
    CHIP_VENDOR = "STMicroelectronics";
    TARGET_ARCH = "arm-none-eabi";
  };
  message = "STM32 environment: arm-none-eabi toolchain, OpenOCD, ST-Link, stm32flash.";
}
