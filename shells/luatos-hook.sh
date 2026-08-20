#!/usr/bin/env bash
# LuatOS devShell hook: riscv64-unknown-elf-* compatibility aliases.
# Sourced by dev_toolchains/embedded/luatos.nix (kept as a real file so Nix
# string interpolation cannot mangle the shell variables).

# CSDK Makefiles hardcode the riscv64-unknown-elf- prefix; Nix provides
# riscv64-none-elf-*. Create a symlink alias directory for compatibility.
ALIAS_DIR="$HOME/.luatos-toolchain"
mkdir -p "$ALIAS_DIR"

for BIN in /nix/store/*riscv64-none-elf*/bin/riscv64-none-elf-*; do
  [ -e "$BIN" ] || continue
  NAME="$(basename "$BIN")"
  TARGET="${NAME/riscv64-none-elf-/riscv64-unknown-elf-}"
  if [ "$TARGET" != "$NAME" ]; then
    ln -sf "$BIN" "$ALIAS_DIR/$TARGET"
  fi
done
export PATH="$ALIAS_DIR:$PATH"
