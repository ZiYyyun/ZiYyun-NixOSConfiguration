{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  nodePackages = import ../libs/node-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "node";
  packages = compilerPackages.node ++ [ nodePackages.deepseek-harness ];
  env = {
    npm_config_registry = "https://registry.npmmirror.com";
  };
  tools = [ "node" "npm" "pnpm" "yarn" "typescript" "typescript-language-server" "eslint" "prettier" "dsh" ];
  versionCommands = [
    { name = "node"; bin = "node"; command = "node --version"; }
    { name = "npm"; bin = "npm"; command = "npm --version"; }
    { name = "pnpm"; bin = "pnpm"; command = "pnpm --version"; }
    { name = "yarn"; bin = "yarn"; command = "yarn --version"; }
    { name = "dsh"; bin = "dsh"; command = "dsh --version"; }
  ];
  message = "Node.js shell: node, pnpm/yarn, TypeScript, typescript-language-server, eslint, prettier and dsh (DeepSeek Harness).";
}
