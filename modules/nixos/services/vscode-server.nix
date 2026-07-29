/**
 * File: vscode-server.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Optional VS Code Server service module.
 */
{ config, pkgs, ... }:
{
  services.vscode-server.enable = true;
}
