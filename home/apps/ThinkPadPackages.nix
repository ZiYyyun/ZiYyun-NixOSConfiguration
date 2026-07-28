# ThinkPadPackages.nix
{ config, pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		tpacpi-bat
		hdapsd
	];
}
