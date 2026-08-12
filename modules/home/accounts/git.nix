/**
 * File: git.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Home Manager Git identity and defaults.
 */
{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "ziyun";
      user.email = "1583931339@qq.com";
      http.version = "HTTP/1.1";
    };
  };
}
