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
    # 重型 IDE：从 JetBrains/Google CDN 拉取，首次 rebuild 可能较久，请耐心等待。
    # 注：nixpkgs 26.05 起 IntelliJ IDEA Ultimate 的包名改为 jetbrains.idea
    # （原 jetbrains.idea-ultimate 已废弃并抛错）。
    jetbrains.idea
    android-studio
    # clangd / clang-tidy：KDevelop 的 C++ 强化插件（Clangd/补全/静态分析）依赖它。
    clang-tools
    # Keep large vendor IDEs out of the default system switch path. They fetch
    # from external CDNs and can make a normal rebuild hang for a long time.
    # jetbrains.clion
    # claude-code
    # dotnet-runtime_7
    # dotnet-runtime_6
    podman
  ];
}
