/**
 * File: default.nix
 * Description: Registry for independently packaged user applications.
 */
{ pkgs }:

let
  dsh = pkgs.callPackage ./source/deepseek-harness { };
in
(import ./winapps {
  inherit (pkgs) callPackage;
})
// {
  trae-code = pkgs.callPackage ./dist/trae-code { };
  codebuddy = pkgs.callPackage ./dist/codebuddy { };
  qwen = pkgs.callPackage ./dist/qwen { };
  flex-movie = pkgs.callPackage ./dist/flex-movie { };
  cc-switch = pkgs.callPackage ./dist/cc-switch { };

  # DeepSeek Harness is a normal application package. Its plugin closure is
  # separate so Home Manager can install the profile declaratively.
  inherit dsh;
  dsh-plugins = pkgs.callPackage ./source/deepseek-harness/plugins.nix {
    inherit dsh;
  };

  webapps = pkgs.callPackage ./dist/webapps { };
  yakuake-skins = pkgs.callPackage ./source/yakuake-skins { };
  qoder-cn = pkgs.callPackage ./dist/qoder { };
  qoder-wake = pkgs.callPackage ./binary/qoder-wake { };
  qoder-cli-cn = pkgs.callPackage ./binary/qoder-cli { };
}
