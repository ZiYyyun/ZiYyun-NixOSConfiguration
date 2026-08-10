/**
 * File: direnv.nix
 * Author: ziyun
 * Date: 2026-08-10
 * Description: direnv integration for per-project Nix development environments.
 */
{ ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
