{ pkgs, ... }:
let
  devCmpPackages = import ../libs/libs_cmp_packages.nix { inherit pkgs; };
  mkDevCmpShell = import ../libs/libs_cmp_shell.nix;
in
mkDevCmpShell {
  inherit pkgs;
  name = "rust";
  packages = devCmpPackages.rust;
  env = {
    RUST_BACKTRACE = "1";
  };
  message = "Rust shell: rustup/rustc/cargo, rust-analyzer, clippy, rustfmt and native build dependencies.";
}
