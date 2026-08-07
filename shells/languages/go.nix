{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "go";
  packages = with pkgs; [
    go
    gopls
    delve
    gotools
    golangci-lint
  ];
  env = {
    GOPROXY = "https://goproxy.cn,direct";
  };
  message = "Go shell: go, gopls, delve, gotools and golangci-lint.";
}
