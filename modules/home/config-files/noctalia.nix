/**
 * File: noctalia.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: Home Manager integration for the Noctalia shell settings.
 *
 * Noctalia keeps user settings in ~/.local/state/noctalia/settings.toml
 * (not XDG config). Export with `shells/export-dotfiles.sh` after tuning
 * in the running session, then rebuild.
 */
{ lib, ... }:
let
  settings = ../../../dotfiles/noctalia/settings.toml;
in
{
  home.file = lib.optionalAttrs (builtins.pathExists settings) {
    ".local/state/noctalia/settings.toml".source = settings;
  };
}
