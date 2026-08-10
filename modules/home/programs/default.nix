/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Home program settings entrypoint.
 */
{ ... }:
{
  imports = [
    ./direnv.nix
    ./nixvim.nix
    ./vscode-server.nix
  ];
}
