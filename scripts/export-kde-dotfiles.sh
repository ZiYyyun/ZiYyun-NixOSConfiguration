#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kde_root="${repo_root}/assets/dotfiles/kde"

config_dir="${kde_root}/config"
share_dir="${kde_root}/local-share"

mkdir -p "${config_dir}" "${share_dir}"

config_files=(
  kdeglobals
  kwinrc
  kglobalshortcutsrc
  kcminputrc
  kscreenlockerrc
  plasma-org.kde.plasma.desktop-appletsrc
  plasmarc
  plasmashellrc
  konsolerc
  gtkrc
  gtkrc-2.0
)

config_dirs=(
  kscreen
)

share_dirs=(
  aurorae
  color-schemes
  desktoptheme
  Kvantum
  look-and-feel
  plasma
  wallpapers
)

for file in "${config_files[@]}"; do
  if [[ -e "${HOME}/.config/${file}" ]]; then
    cp -a "${HOME}/.config/${file}" "${config_dir}/"
  fi
done

for dir in "${config_dirs[@]}"; do
  if [[ -e "${HOME}/.config/${dir}" ]]; then
    rm -rf "${config_dir:?}/${dir}"
    cp -a "${HOME}/.config/${dir}" "${config_dir}/"
  fi
done

for dir in "${share_dirs[@]}"; do
  if [[ -e "${HOME}/.local/share/${dir}" ]]; then
    rm -rf "${share_dir:?}/${dir}"
    cp -a "${HOME}/.local/share/${dir}" "${share_dir}/"
  fi
done

cat <<EOF
Exported KDE dotfiles into ${kde_root}

Icon themes are intentionally not exported here. Many icon themes contain large
symlink forests that are fragile on Windows worktrees. Prefer packaging icon
themes with Nix, or archive/deploy them separately from a Linux checkout.
EOF
