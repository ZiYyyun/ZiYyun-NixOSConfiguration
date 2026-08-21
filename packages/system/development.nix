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
    eclipses.eclipse-embedcpp
    kicad
    codeblocks
    # TraeCode AI IDE (local deb packaging, cached in store after first build).
    (pkgs.callPackage ../../packages/custom/trae-code { })
    # Keep large vendor IDEs out of the default system switch path. They fetch
    # from external CDNs and can make a normal rebuild hang for a long time.
    # jetbrains.clion
    # claude-code
    # dotnet-runtime_7
    # dotnet-runtime_6
  ];
}
