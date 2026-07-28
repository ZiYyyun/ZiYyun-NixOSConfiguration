#Dev_Pkgs.nix
#Created by ziyun 2026.7.17 23:53
{ config, pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
	neovim
  vscode
  lmstudio
# claude-code
  docker
  jetbrains.clion
	eclipses.eclipse-embedcpp
	stm32cubemx
	kicad
	clang
	cmake
	codeblocks
	gcc
	# dotnet-runtime_7
	# dotnet-runtime_6
	];
}
