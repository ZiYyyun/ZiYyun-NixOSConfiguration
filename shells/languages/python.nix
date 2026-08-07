{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "python";
  packages = with pkgs; [
    python3
    uv
    ruff
    pyright
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.ipython
    pkg-config
    gcc
  ];
  env = {
    UV_LINK_MODE = "copy";
  };
  message = "Python shell: python3, uv, pip/virtualenv, ruff, pyright and native build helpers.";
}
