#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/ZiYyun/ZiYyun-NixOSConfiguration.git"
branch="main"
workdir="/tmp/ziyyun-nixos-config"
install_args=()

usage() {
  cat <<'EOF'
Usage:
  sudo bash bootstrap.sh [options] [-- install-options]

Options:
  --repo URL       Git repository URL.
  --branch NAME    Git branch to checkout. Default: main.
  --workdir PATH   Temporary clone path. Default: /tmp/ziyyun-nixos-config.
  -h, --help       Show this help.

Examples:
  curl -L https://raw.githubusercontent.com/ZiYyun/ZiYyun-NixOSConfiguration/main/scripts/bootstrap.sh | sudo bash

  sudo bash bootstrap.sh -- --mountpoint /mnt --flake nixos
  sudo bash bootstrap.sh -- --disk /dev/sda --erase --flake nixos
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo_url="${2:?missing value for --repo}"
      shift 2
      ;;
    --branch)
      branch="${2:?missing value for --branch}"
      shift 2
      ;;
    --workdir)
      workdir="${2:?missing value for --workdir}"
      shift 2
      ;;
    --)
      shift
      install_args=("$@")
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root, for example: curl -L <url> | sudo bash" >&2
  exit 1
fi

run_git() {
  if command -v git >/dev/null 2>&1; then
    git "$@"
  else
    local quoted=""
    printf -v quoted "%q " git "$@"
    nix-shell -p git --run "$quoted"
  fi
}

echo "[bootstrap] repository: ${repo_url}"
echo "[bootstrap] branch: ${branch}"
echo "[bootstrap] workdir: ${workdir}"

if [[ -d "${workdir}/.git" ]]; then
  echo "[bootstrap] updating existing clone"
  run_git -C "${workdir}" fetch origin "${branch}"
  run_git -C "${workdir}" checkout "${branch}"
  run_git -C "${workdir}" pull --ff-only origin "${branch}"
else
  if [[ -e "${workdir}" ]]; then
    echo "Workdir exists but is not a git repository: ${workdir}" >&2
    exit 1
  fi
  echo "[bootstrap] cloning configuration repository"
  run_git clone --branch "${branch}" "${repo_url}" "${workdir}"
fi

exec bash "${workdir}/scripts/install.sh" "${install_args[@]}"
