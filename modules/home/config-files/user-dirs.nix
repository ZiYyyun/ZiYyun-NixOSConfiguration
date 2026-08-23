/**
 * File: user-dirs.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: XDG 用户目录改英文（Documents/Downloads/Pictures/...）。
 *
 * 中文目录名来自 zh_CN locale 下 xdg-user-dirs 的默认生成；这里用
 * home-manager 声明覆盖，并 createDirectories 自动建英文目录。
 * 目录内容迁移（mv）由仓库里的 switch 后手动步骤/脚本完成一次。
 */
{ config, lib, pkgs, ... }:
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    download = "$HOME/Downloads";
    documents = "$HOME/Documents";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    templates = "$HOME/Templates";
    publicShare = "$HOME/Public";
  };
}
