/**
 * File: vscode-server.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Home Manager VS Code Server integration.
 */
{ pkgs, ... }:
{
  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs;
  };
}
