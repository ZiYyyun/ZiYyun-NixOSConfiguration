/**
 * File: general.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: General development tools and IDE packages.
 */
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (callPackage ../../../../pkgs/trae { })
    neovim
    vscode
    lmstudio
    # claude-code
    docker
    jetbrains.clion
    eclipses.eclipse-embedcpp
    kicad
    clang
    codeblocks
    filezilla
    # dotnet-runtime_7
    # dotnet-runtime_6
  ];
}
