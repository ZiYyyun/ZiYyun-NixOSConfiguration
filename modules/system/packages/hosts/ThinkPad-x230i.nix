/**
 * File: ThinkPad-x230i.nix
 * Author: ziyun
 * Date: 2026-07-31
 * Description: Host profile for Lenovo ThinkPad X230i.
 */
{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # nixos-hardware does not provide a separate X230i profile; X230 is the
    # closest official ThinkPad profile for this generation.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230
  ];
}
