{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedMcuShell = import ../libs/embedded-mcu-shell.nix;
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "stm";
  packages = embeddedPackages.stm;
  env = {
    CHIP_VENDOR = "STMicroelectronics";
    TARGET_ARCH = "arm-none-eabi";
  };
  tools = [ "arm-none-eabi gcc" "openocd" "probe-rs-tools" "stlink" "stm32flash" "dfu-util" "serial tools" ];
  versionCommands = [
    { name = "arm-none-eabi-gcc"; bin = "arm-none-eabi-gcc"; command = "arm-none-eabi-gcc --version"; }
    { name = "openocd"; bin = "openocd"; command = "openocd --version"; }
    { name = "stm32flash"; bin = "stm32flash"; command = "stm32flash -h"; }
  ];
  message = "STM32 environment: arm-none-eabi toolchain, OpenOCD, ST-Link, stm32flash.";
}
