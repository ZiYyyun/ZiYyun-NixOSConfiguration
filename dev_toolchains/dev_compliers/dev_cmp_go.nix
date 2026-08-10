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
  message = "Go shell: go, gopls, delve, gotools and golangci-lint.";
}
