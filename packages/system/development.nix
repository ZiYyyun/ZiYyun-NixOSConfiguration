/**
 * File: development.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Global IDE and GUI development tools.
 */
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    vscode
    jetbrains.clion
    eclipses.eclipse-embedcpp
    kicad
    codeblocks
    # claude-code
    # dotnet-runtime_7
    # dotnet-runtime_6
  ];
}
