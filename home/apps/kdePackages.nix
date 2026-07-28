# KDE SoftWare Packages
# Created by ziyun 2026.6.28

{ config, pkgs, ... }:
{
	environment.systemPackages = with pkgs; [

	kdePackages.discover
	kdePackages.marble
	kdePackages.okular
	
	];
}
