{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "python";
  packages = compilerPackages.python;
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
