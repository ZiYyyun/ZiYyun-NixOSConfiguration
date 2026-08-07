{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "node";
  packages = with pkgs; [
    nodejs
    pnpm
    yarn
    typescript
    typescript-language-server
    prettier
    eslint
  ];
  env = {
    npm_config_registry = "https://registry.npmmirror.com";
  };
  message = "Node.js shell: node, pnpm/yarn, TypeScript, typescript-language-server, eslint and prettier.";
}
