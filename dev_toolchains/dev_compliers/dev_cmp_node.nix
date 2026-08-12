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
  tools = [ "node" "npm" "pnpm" "yarn" "typescript" "typescript-language-server" "eslint" "prettier" ];
  versionCommands = [
    { name = "node"; bin = "node"; command = "node --version"; }
    { name = "npm"; bin = "npm"; command = "npm --version"; }
    { name = "pnpm"; bin = "pnpm"; command = "pnpm --version"; }
    { name = "yarn"; bin = "yarn"; command = "yarn --version"; }
  ];
  message = "Node.js shell: node, pnpm/yarn, TypeScript, typescript-language-server, eslint and prettier.";
}
