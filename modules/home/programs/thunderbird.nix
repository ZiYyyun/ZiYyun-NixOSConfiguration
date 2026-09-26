/**
 * File: thunderbird.nix
 * Author: ziyun
 * Date: 2026-09-26
 * Description: Thunderbird 从 Flatpak 迁移到 nixpkgs 原生版 + home-manager 声明式管理。
 *
 * 复现边界（有意为之）：
 *  - 可复现：profile、偏好设置（settings → user_pref）、过滤规则等纯文本配置。
 *  - 不可复现且不进仓库：密码/OAuth token（logins.json + key4.db）。
 *    把它们放进 dotfiles 等于泄露全部邮箱凭据。新机器 rebuild 后只需
 *    手动登录一次；建议设置主密码后用加密渠道单独同步 key4.db/logins.json。
 *
 * 账户（服务器/身份）暂不声明——需要邮箱地址与凭据方案，后续用
 * programs.thunderbird.accounts 或 profile.settings 补充。
 */
{ pkgs, ... }:
{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird;

    profiles.main = {
      isDefault = true;
      settings = {
        # 跳过首次运行向导/账户创建向导提示。
        "mailnews.start_page.override_url" = "about:blank";
        "app.shield.optoutstudies.enabled" = false;
        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
      };
    };
  };
}
