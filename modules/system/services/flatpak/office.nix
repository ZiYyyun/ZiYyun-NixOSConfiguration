/**
 * File: office.nix
 * Author: ziyun
 * Date: 2026-08-21
 * Description: 办公/文档/笔记类 Flatpak 应用。
 */
{ ... }:

{
  services.flatpak.packages = [
    # 办公套件
    "org.onlyoffice.desktopeditors"
    "com.wps.Office"
    # 邮件
    "org.mozilla.thunderbird"
    # 笔记/知识管理
    "md.obsidian.Obsidian"
  ];
}
