#!/usr/bin/env bash
set -euo pipefail

flake="kde-default"
mountpoint="/mnt"
disk=""
erase="false"
skip_flake_check="false"
skip_install="false"

usage() {
  cat <<'EOF'
Usage:
  sudo bash scripts/install.sh [options]

Options:
  --flake NAME          Flake output name. Default: kde-default.
  --mountpoint PATH     Installation root. Default: /mnt.
  --disk DEVICE         Target disk, for example /dev/sda or /dev/nvme0n1.
  --erase               Partition and format --disk, then mount it.
  --skip-flake-check    Skip "nix flake check".
  --skip-install        Prepare files only; do not run nixos-install.
  -h, --help            Show this help.

Modes:
  Existing mount mode:
    1. Partition, format, and mount manually.
    2. Run: sudo bash scripts/install.sh --mountpoint /mnt

  Full disk mode:
    sudo bash scripts/install.sh --disk /dev/sda --erase
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flake)
      flake="${2:?missing value for --flake}"
      shift 2
      ;;
    --mountpoint)
      mountpoint="${2:?missing value for --mountpoint}"
      shift 2
      ;;
    --disk)
      disk="${2:?missing value for --disk}"
      shift 2
      ;;
    --erase)
      erase="true"
      shift
      ;;
    --skip-flake-check)
      skip_flake_check="true"
      shift
      ;;
    --skip-install)
      skip_install="true"
      shift
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
  echo "Please run as root." >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export NIX_CONFIG="${NIX_CONFIG:-}
experimental-features = nix-command flakes
"

log() {
  echo "[install] $*"
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

partition_suffix() {
  case "$1" in
    *[0-9]) printf 'p%s' "$2" ;;
    *) printf '%s' "$2" ;;
  esac
}

write_boot_override() {
  local target_disk="$1"
  local boot_file="${repo_root}/hosts/common/installation-boot.nix"

  if [[ -d /sys/firmware/efi ]]; then
    cat >"${boot_file}" <<EOF
{ lib, ... }:
{
  boot.loader.grub.device = lib.mkForce "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
}
EOF
  else
    cat >"${boot_file}" <<EOF
{ lib, ... }:
{
  boot.loader.grub.device = lib.mkForce "${target_disk}";
  boot.loader.grub.useOSProber = true;
}
EOF
  fi
}

prepare_disk() {
  [[ -n "${disk}" ]] || die "--disk is required with --erase"
  [[ -b "${disk}" ]] || die "not a block device: ${disk}"

  require_command lsblk
  require_command parted
  require_command mkfs.ext4
  require_command mount

  log "target disk:"
  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL "${disk}"
  echo
  echo "This will erase all data on ${disk}."
  read -r -p "Type ERASE ${disk} to continue: " confirmation
  [[ "${confirmation}" == "ERASE ${disk}" ]] || die "confirmation did not match"

  log "partitioning ${disk}"
  if [[ -d /sys/firmware/efi ]]; then
    require_command mkfs.fat
    parted --script "${disk}" \
      mklabel gpt \
      mkpart ESP fat32 1MiB 513MiB \
      set 1 esp on \
      mkpart root ext4 513MiB 100%
    partprobe "${disk}" || true
    sleep 2

    local esp="${disk}$(partition_suffix "${disk}" 1)"
    local root="${disk}$(partition_suffix "${disk}" 2)"
    mkfs.fat -F 32 -n NIXBOOT "${esp}"
    mkfs.ext4 -F -L nixos "${root}"

    mkdir -p "${mountpoint}"
    mount "${root}" "${mountpoint}"
    mkdir -p "${mountpoint}/boot"
    mount "${esp}" "${mountpoint}/boot"
  else
    parted --script "${disk}" \
      mklabel gpt \
      mkpart primary 1MiB 3MiB \
      set 1 bios_grub on \
      mkpart root ext4 3MiB 100%
    partprobe "${disk}" || true
    sleep 2

    local root="${disk}$(partition_suffix "${disk}" 2)"
    mkfs.ext4 -F -L nixos "${root}"

    mkdir -p "${mountpoint}"
    mount "${root}" "${mountpoint}"
  fi

  write_boot_override "${disk}"
}

check_mountpoint() {
  [[ -d "${mountpoint}" ]] || die "mountpoint does not exist: ${mountpoint}"
  mountpoint -q "${mountpoint}" || die "${mountpoint} is not mounted. Mount your target root first, or use --disk DEVICE --erase."
}

copy_repo() {
  local target="${mountpoint}/etc/nixos"
  log "copying repository to ${target}"
  mkdir -p "${mountpoint}/etc"

  if [[ -e "${target}" && ! -d "${target}/.git" ]]; then
    die "${target} exists but is not this repository"
  fi

  if [[ ! -d "${target}/.git" ]]; then
    cp -a "${repo_root}" "${target}"
  else
    if [[ "$(realpath "${repo_root}")" == "$(realpath "${target}")" ]]; then
      log "repository is already at ${target}"
      return
    fi
    cp -a "${repo_root}/." "${target}/"
  fi
}

generate_hardware_config() {
  log "generating hardware configuration"
  nixos-generate-config --root "${mountpoint}"

  local generated="${mountpoint}/etc/nixos/hardware-configuration.nix"
  local target="${mountpoint}/etc/nixos/hosts/common/hardware-configuration.nix"
  [[ -f "${generated}" ]] || die "nixos-generate-config did not create ${generated}"
  mkdir -p "$(dirname "${target}")"
  cp "${generated}" "${target}"
  rm -f "${generated}"
}

run_checks_and_install() {
  cd "${mountpoint}/etc/nixos"

  if [[ "${skip_flake_check}" != "true" ]]; then
    log "running nix flake check"
    nix --extra-experimental-features "nix-command flakes" flake check
  fi

  if [[ "${skip_install}" == "true" ]]; then
    log "skipping nixos-install because --skip-install was set"
    return
  fi

  log "running nixos-install --flake .#${flake}"
  nixos-install --flake ".#${flake}"
}

require_command nix
require_command nixos-generate-config
require_command nixos-install

if [[ "${erase}" == "true" ]]; then
  prepare_disk
else
  if [[ -n "${disk}" ]]; then
    write_boot_override "${disk}"
  fi
  check_mountpoint
fi

copy_repo
generate_hardware_config
run_checks_and_install

log "done"
