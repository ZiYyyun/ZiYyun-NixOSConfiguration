/**
 * File: noctalia.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: Home Manager integration for Noctalia via out-of-store symlink.
 *
 * Noctalia keeps user settings in ~/.local/state/noctalia/settings.toml
 * (not XDG config). The repo file dotfiles/noctalia/settings.toml is
 * symlinked there directly, so edits take effect immediately without rebuild.
 * If Noctalia itself saves settings (atomic rename), the symlink is replaced;
 * restore with `home-manager switch` or copy the file back into the repo.
 */
{ config, ... }:
let
  repoFile = "/home/ziyun/文档/GitHub/ZiYyun-NixOSConfiguration/dotfiles/noctalia/settings.toml";
in
{
  home.file.".local/state/noctalia/settings.toml".source = config.lib.file.mkOutOfStoreSymlink repoFile;
}
