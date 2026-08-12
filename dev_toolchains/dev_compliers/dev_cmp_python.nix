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
  tools = [ "python3" "uv" "pip" "virtualenv" "ruff" "pyright" ];
  versionCommands = [
    { name = "python"; bin = "python"; command = "python --version"; }
    { name = "uv"; bin = "uv"; command = "uv --version"; }
    { name = "ruff"; bin = "ruff"; command = "ruff --version"; }
    { name = "pyright"; bin = "pyright"; command = "pyright --version"; }
  ];
  message = "Python shell: python3, uv, pip/virtualenv, ruff, pyright and native build helpers.";
}
