/**
 * File: edge.nix
 * Author: ziyun
 * Date: 2026-09-25
 * Description: Microsoft Edge 浏览器声明式配置（扩展复现）。
 *
 * Edge/Chromium 在 Linux 上从 /etc/opt/edge/policies/managed/*.json 读取
 * 企业策略（不读用户目录），ExtensionSettings 策略可按 ID 从 Edge Add-ons
 * 商店强制安装扩展，实现 dotfiles 式的扩展复现。
 *
 * 扩展 ID 来源：当前系统 ~/.config/microsoft-edge/Default/Extensions，
 * 其 manifest 的 update_url 均为 edge.microsoft.com/extensionwebstorebase
 * （即 Edge Add-ons 商店）。"Edge relevant text changes" 为 Edge 内置
 * 服务扩展，由浏览器自动安装，不在此管理。
 */
{ ... }:

let
  # Edge Add-ons 商店的 CRX 更新地址（所有扩展同源）。
  edgeStoreUrl = "https://edge.microsoft.com/extensionwebstorebase/v1/crx";

  # 要复现的扩展：ID -> 名称（名称仅作注释用途）。
  extensions = {
    "alhnbdjjbokpmilgemopoomnldpejihb" = "GitHub加速";
    "ameobllgfelffdengghkfoeagpohnhjk" = "Download Master";
    "eeebhkdldehjoidiochkpdpbeefdkill" = "LuLu Translate";
    "eigdjhmgnaaeaonimdklocfekkaanfme" = "Obsidian Web Clipper";
    "odlomjlbamekndcpllcnffbgeohgkmjh" = "ChatGPT";
    "okdacpiidbbphpjpfmecjjhicomjdeie" = "360 Internet Protection";
    "oohmdefbjalncfplafanlagojlakmjci" = "cat-catch";
  };

  extensionSettings = builtins.mapAttrs (id: _name: {
    installation_mode = "force_installed";
    external_update_url = edgeStoreUrl;
  }) extensions;

in
{
  environment.etc."opt/edge/policies/managed/extensions.json".text =
    builtins.toJSON { ExtensionSettings = extensionSettings; };
}
