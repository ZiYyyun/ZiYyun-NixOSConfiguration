{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "go";
  packages = devCmpPackages.go;
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
