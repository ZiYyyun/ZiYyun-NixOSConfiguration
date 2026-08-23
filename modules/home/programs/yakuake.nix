/**
 * File: yakuake.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: Yakuake 下拉终端：皮肤集挂载 + F12 全局快捷键声明。
 *
 * 皮肤：packages/custom/yakuake-skins 构建出 15 个皮肤（商店 top + GitHub
 * 官方），链接到 ~/.local/share/yakuake/skins（yakuake 一定扫描的目录）。
 * 在 Yakuake 设置 → 外观 → 皮肤 里切换。
 *
 * F12：kglobalshortcutsrc 是全局文件（其他应用共享），不能整体接管，
 * 用幂等 activation 脚本只维护 [yakuake] 段的 toggle-window-state 键。
 * 注意：在系统设置里手动改过 Yakuake 快捷键的话，home-manager switch 会
 * 重置回 F12（想改就改这里）。
 */
{ config, lib, pkgs, ... }:

let
  yakuakeSkins = pkgs.callPackage ../../../packages/custom/yakuake-skins { };
in
{
  home.file = {
    ".local/share/yakuake/skins".source = "${yakuakeSkins}/share/yakuake/skins";
  };

  home.activation.yakuakeF12Shortcut = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="$HOME/.config/kglobalshortcutsrc"
    touch "$f"
    # 幂等：先删旧键再写，保证每次 switch 后都是 F12
    sed -i "/^toggle-window-state=/d" "$f"
    if grep -q "^\[yakuake\]" "$f"; then
      sed -i "/^\[yakuake\]/a toggle-window-state=F12,F12,展开/折叠 Yakuake 窗口" "$f"
    else
      printf "\n[yakuake]\n_k_friendly_name=Yakuake 下拉式终端\ntoggle-window-state=F12,F12,展开/折叠 Yakuake 窗口\n" >> "$f"
    fi
  '';
}
