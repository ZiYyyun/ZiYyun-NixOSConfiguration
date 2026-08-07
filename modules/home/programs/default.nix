/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Home program settings entrypoint.
 */
{ ... }:
{
  imports = [
    ./nixvim.nix
    ./vscode-server.nix
  ];
}
