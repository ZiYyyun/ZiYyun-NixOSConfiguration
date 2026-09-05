/**
 * File: kde.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: KDE dotfiles 集成 —— activation 强制覆盖模式（v2）。
 *
 * v1 用 home.file/xdg.configFile 链接，但 KDE 保存设置时原子替换（temp+rename）
 * 会把链接换成普通文件 → 下次 rebuild home-manager 报 "would be clobbered"
 * → 配置更新失败 → "一 rebuild KDE 就坏" 的恶性循环。
 *
 * v2 改为 activation 脚本：每次 switch 把仓库 dotfiles 强制 cp 到 ~/.config，
 * 不依赖链接、不检查目标类型，KDE 随便保存，下次 switch 自动恢复声明配置。
 * 代价：KDE 里手动改的设置会在下次 switch 被重置（声明式的本质）。
 */
{ config, lib, pkgs, ... }:

let
  # 仓库实际位置（注意：xdg-user-dirs 可能把「文档」改成 Documents，
  # 这里必须与真实仓库路径一致，否则 activation 会拷错文件）。
  dotfilesRoot = "/home/ziyun/Documents/GitHub/ZiYyun-NixOSConfiguration/dotfiles";
  configRoot = "${dotfilesRoot}/kde/config";
  wallpapersRoot = "${dotfilesRoot}/kde/wallpapers";

  link = config.lib.file.mkOutOfStoreSymlink;

  # 每次 switch 强制覆盖的 KDE 配置文件（仓库 → ~/.config）
  managedFiles = [
    "plasma-org.kde.plasma.desktop-appletsrc"
    "plasma-localerc"
    "kdeglobals"
    "kwinrc"
    "plasmashellrc"
  ];

  copyOne = f: "${pkgs.coreutils}/bin/cp -f \"${configRoot}/${f}\" \"$HOME/.config/${f}\"";
  copyCmds = lib.concatStringsSep "\n" (map copyOne managedFiles);

  # KDevelop 编辑器偏好：用 kwriteconfig6 精确合并进 ~/.config/kdeveloprc，
  # 只写 [KTextEditor Editor] 段（字体 + 配色），不影响 KDevelop 的
  # 会话/最近文件等动态配置。值声明见 dotfiles/kde/config/kdeveloprc。
  kwriteconfig6 = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";
  kdevelopEditorCmds = with pkgs.kdePackages; [
    "${kwriteconfig6} --file kdeveloprc --group 'KTextEditor Editor' --key 'Text Font' 'Mononoki,12,-1,5,50,0,0,0,0,0,Regular'"
    "${kwriteconfig6} --file kdeveloprc --group 'KTextEditor Editor' --key 'Color Theme' 'Breeze Dark'"
  ];
in
{
  home.pointerCursor = {
    package = pkgs.oreo-cursors-plus;
    name = "oreo_purple_cursors";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  # 壁纸目录 KDE 不会写，用普通链接即可。
  xdg.dataFile = lib.mkMerge [
    {
      "wallpapers".source = link wallpapersRoot;
    }
  ];

  home.activation.kdeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${copyCmds}
    ${lib.concatStringsSep "\n" kdevelopEditorCmds}
  '';
}
