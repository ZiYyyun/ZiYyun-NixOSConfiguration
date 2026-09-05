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
    # clangd / clang-tidy：KDevelop 的 C++ 强化插件（Clangd/补全/静态分析）依赖它。
    clang-tools
    # Keep large vendor IDEs out of the default system switch path. They fetch
    # from external CDNs and can make a normal rebuild hang for a long time.
    # jetbrains.clion
    # claude-code
    # dotnet-runtime_7
    # dotnet-runtime_6
  ];
}
