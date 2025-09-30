#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/lafayettegabe/homelab"
BRANCH="main"

# must be root
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run as root (sudo)."
  exit 1
fi

echo "==> Ensuring required tools"
if ! nix-channel --list | grep -q nixpkgs; then
  echo "Adding nixpkgs channel..."
  nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
  nix-channel --update
fi

nix-env -iA nixpkgs.git nixpkgs.dosfstools nixpkgs.e2fsprogs nixpkgs.btrfs-progs nixpkgs.xfsprogs nixpkgs.rsync >/dev/null 2>&1 || {
  echo "Warning: Some tools may not be available, continuing anyway..."
}

echo "==> Detecting root and EFI partitions"
ROOT_DEV="$(findmnt -n -o SOURCE /)"
ROOT_FSTYPE="$(findmnt -n -o FSTYPE /)"
# try /boot/efi first, then /boot
EFI_DEV="$(findmnt -n -o SOURCE /boot/efi 2>/dev/null || true)"
if [[ -z "${EFI_DEV}" ]]; then
  EFI_DEV="$(findmnt -n -o SOURCE /boot 2>/dev/null || true)"
fi

if [[ -z "${ROOT_DEV}" ]]; then echo "Cannot detect root device"; exit 1; fi
if [[ -z "${EFI_DEV}" ]]; then echo "Cannot detect EFI (/boot or /boot/efi) device"; exit 1; fi

echo "Root: ${ROOT_DEV} (fs=${ROOT_FSTYPE})"
echo "EFI : ${EFI_DEV}"

echo "==> Labeling root as NIXOS_ROOT"
case "${ROOT_FSTYPE}" in
  ext4)
    e2label "${ROOT_DEV}" NIXOS_ROOT || tune2fs -L NIXOS_ROOT "${ROOT_DEV}"
    ;;
  btrfs)
    # online relabel is fine on btrfs
    btrfs filesystem label / NIXOS_ROOT
    ;;
  xfs)
    echo "XFS root cannot be relabeled while mounted; use ext4/btrfs for root or relabel offline."
    exit 1
    ;;
  *)
    echo "Unsupported root fs '${ROOT_FSTYPE}'. Use ext4 or btrfs for this script."
    exit 1
    ;;
esac

echo "==> Labeling EFI as NIXOS_EFI"
# Works on mounted vfat in most cases
dosfslabel "${EFI_DEV}" NIXOS_EFI || fatlabel "${EFI_DEV}" NIXOS_EFI || true

echo "==> Replacing /etc/nixos with local homelab contents"
backup_dir="/etc/nixos.backup.$(date +%s)"
if [[ -d /etc/nixos ]]; then
  cp -a /etc/nixos "${backup_dir}" || true
  rm -rf /etc/nixos
fi
mkdir -p /etc/nixos


if [[ -f "configuration.nix" ]]; then
  cp -r . /etc/nixos/
else
  echo "Error: Please run this script from the homelab directory"
  echo "Current directory: $(pwd)"
  echo "Expected files: configuration.nix, modules/, secrets/, etc."
  exit 1
fi

echo "==> Fixing permissions"
if [[ -d /etc/nixos/secrets ]]; then
  chmod 700 /etc/nixos/secrets || true
  [[ -f /etc/nixos/secrets/homelab_ed25519 ]] && chmod 600 /etc/nixos/secrets/homelab_ed25519 || true
  [[ -f /etc/nixos/secrets/homelab_authorized_keys.pub ]] && chmod 644 /etc/nixos/secrets/homelab_authorized_keys.pub || true
fi

echo "==> Applying configuration"
nixos-rebuild switch

echo "==> Done. Kubeconfig at /etc/rancher/k3s/k3s.yaml"
