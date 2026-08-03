/**
 * File: home.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Home Manager user configuration for ziyun.
 */
{ config, pkgs, ... }:
{
  # Optional KDE dotfiles module, kept disabled until the exported files are ready.
  # imports = [ ./dotfiles ];

  home.stateVersion = "26.05";   # 与系统版本保持一致
  programs.git = { 
	enable = true; 
	settings = {
	  user.name = "ziyun";
	  user.email = "1583931339@qq.com";
	};
	};

  home.packages = with pkgs; [
	spotify
	winboat
  clash-verge-rev
	obsidian
	koodo-reader
	qq
	# steam
	microsoft-edge
	eudic
	libreoffice
	wine
	# wechat
	];
}
