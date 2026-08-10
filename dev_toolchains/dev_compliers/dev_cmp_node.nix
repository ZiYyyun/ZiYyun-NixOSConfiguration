{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "node";
  packages = devCmpPackages.node;
  env = {
    npm_config_registry = "https://registry.npmmirror.com";
  };
  message = "Node.js shell: node, pnpm/yarn, TypeScript, typescript-language-server, eslint and prettier.";
}
