{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sunxi-tools
    xfel
  ];
}