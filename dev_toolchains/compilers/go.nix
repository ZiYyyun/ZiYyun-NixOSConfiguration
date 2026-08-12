{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "go";
  packages = compilerPackages.go;
  env = {
    GOPROXY = "https://goproxy.cn,direct";
  };
  tools = [ "go" "gopls" "delve" "gotools" "golangci-lint" ];
  versionCommands = [
    { name = "go"; bin = "go"; command = "go version"; }
    { name = "golangci-lint"; bin = "golangci-lint"; command = "golangci-lint version"; }
  ];
  message = "Go shell: go, gopls, delve, gotools and golangci-lint.";
}
