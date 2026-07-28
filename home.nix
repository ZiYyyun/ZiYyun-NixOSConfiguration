{ config, pkgs, ... }:
{
  home.stateVersion = "26.05";   # 与系统版本保持一致
  programs.git = { 
	enable = true; 
	userName = "ziyun"; 
	userEmail = "1583931339@qq.com"; 
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
