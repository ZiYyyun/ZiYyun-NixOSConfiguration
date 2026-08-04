#!/usr/bin/env bash
set -euo pipefail

flake="${1:-kde-default}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${repo_root}"
sudo env NIXOS_NO_CHECK=1 nixos-rebuild switch --flake ".#${flake}"
