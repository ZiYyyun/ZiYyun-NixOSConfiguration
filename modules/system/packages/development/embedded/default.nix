/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-03
 * Description: Vendor-specific embedded package module entrypoint.
 */
{ ... }:
{
  imports = [
    ./espressif.nix
    ./stm.nix

    # Allwinner tools remain in devShells for SoC work. Nordic is kept out of
    # the shared system profile because one package still pulls obsolete Qt4.
    # ./Allwinner.nix
    # ./nordic.nix
  ];
}
