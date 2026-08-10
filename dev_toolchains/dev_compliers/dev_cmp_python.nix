{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "python";
  packages = devCmpPackages.python;
  env = {
    UV_LINK_MODE = "copy";
  };
  message = "Python shell: python3, uv, pip/virtualenv, ruff, pyright and native build helpers.";
}
