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
    ./dsh.nix
    ./nixvim.nix
    ./vscode-server.nix
    ./yakuake.nix
  ];
}
