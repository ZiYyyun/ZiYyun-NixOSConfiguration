{ pkgs, ... }:
let
  compilerPackages = import ../libs/compiler-packages.nix { inherit pkgs; };
  mkCompilerShell = import ../libs/compiler-shell.nix;
in
mkCompilerShell {
  inherit pkgs;
  name = "rust";
  packages = compilerPackages.rust;
  env = {
    RUST_BACKTRACE = "1";
  };
  tools = [ "rustup" "rustc" "cargo" "rust-analyzer" "clippy" "rustfmt" ];
  versionCommands = [
    { name = "rustc"; bin = "rustc"; command = "rustc --version"; }
    { name = "cargo"; bin = "cargo"; command = "cargo --version"; }
    { name = "rust-analyzer"; bin = "rust-analyzer"; command = "rust-analyzer --version"; }
  ];
  message = "Rust shell: rustup/rustc/cargo, rust-analyzer, clippy, rustfmt and native build dependencies.";
}
