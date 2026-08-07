{ pkgs, ... }:
let
  mkLanguageShell = import ../lib/mk-language-shell.nix;
in
mkLanguageShell {
  inherit pkgs;
  name = "rust";
  packages = with pkgs; [
    rustup
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
    pkg-config
    openssl
    cmake
    gnumake
    gcc
  ];
  env = {
    RUST_BACKTRACE = "1";
  };
  message = "Rust shell: rustup/rustc/cargo, rust-analyzer, clippy, rustfmt and native build dependencies.";
}
