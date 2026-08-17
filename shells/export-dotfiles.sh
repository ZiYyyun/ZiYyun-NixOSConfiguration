#!/usr/bin/env bash
# 一键导出当前会话里调教好的桌面配置回仓库 dotfiles/。
#
# Nix 是单向声明式的（仓库 -> 系统），没有内置的反向同步命令。
# 调好 KDE / Niri / Noctalia 之后，跑本脚本把成果收进仓库，
# 然后 rebuild 让其他机器/下次安装复现。
#
# 用法：
#   bash shells/export-dotfiles.sh
#
# 导出的内容：
#   KDE      ~/.config/{kdeglobals,kwinrc,plasmashellrc}  -> dotfiles/kde/config/
#            ~/.config/plasma-org.kde.plasma.desktop-appletsrc
#            ~/.config/plasma-localerc
#   Niri     ~/.config/niri/config.kdl                    -> dotfiles/niri/config.kdl
#   Noctalia ~/.local/state/noctalia/settings.toml        -> dotfiles/noctalia/settings.toml
#
# 注意：KDE 的 appletsrc / plasma-localerc / niri config.kdl 可能是 Home
# Manager 的只读链接，cp 会跟随链接复制其内容（即仓库当前版本），幂等。
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kde_dir="${repo_root}/dotfiles/kde/config"
niri_file="${repo_root}/dotfiles/niri/config.kdl"
noctalia_dir="${repo_root}/dotfiles/noctalia"

mkdir -p "${kde_dir}" "${noctalia_dir}"

copy_if_exists() { # source target
  if [[ -e "$1" ]]; then
    # -L: 源可能是 Home Manager 的只读符号链接，必须复制真实内容，
    #     不能把指向 /nix/store 的链接原样带进仓库
    cp -L "$1" "$2"
    echo "  exported: $1 -> $2"
  else
    echo "  skipped (not present): $1"
  fi
}

echo "==> KDE"
copy_if_exists "${HOME}/.config/kdeglobals" "${kde_dir}/kdeglobals"
copy_if_exists "${HOME}/.config/kwinrc" "${kde_dir}/kwinrc"
copy_if_exists "${HOME}/.config/plasmashellrc" "${kde_dir}/plasmashellrc"
copy_if_exists "${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc" "${kde_dir}/plasma-org.kde.plasma.desktop-appletsrc"
copy_if_exists "${HOME}/.config/plasma-localerc" "${kde_dir}/plasma-localerc"

echo "==> Niri"
copy_if_exists "${HOME}/.config/niri/config.kdl" "${niri_file}"

echo "==> Noctalia"
copy_if_exists "${HOME}/.local/state/noctalia/settings.toml" "${noctalia_dir}/settings.toml"

cat <<EOF

导出完成。把改动提交并 rebuild 后，配置即固化进 flake：

  git add dotfiles
  git commit -m "sync dotfiles"
  sudo nixos-rebuild switch --flake .#ThinkPad-P14s
EOF
