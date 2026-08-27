#!/usr/bin/env bash

# Vendor Bashloom into another project from a checked-out source tree.
#
# Default destination:
#   ./vendor/bashloom
#
# The complete src tree is copied so both the full entrypoint and selective
# loader remain available to the consuming project.

set -Eeuo pipefail

TOOL_DIR=${BASH_SOURCE[0]%/*}
[[ $TOOL_DIR == "${BASH_SOURCE[0]}" ]] && TOOL_DIR=.
REPO_ROOT="$(cd -- "$TOOL_DIR/.." && pwd)"

destination=vendor/bashloom
force=0

usage() {
  cat <<'EOF'
Usage: tools/vendor.sh [--destination DIR] [--force]

Copy Bashloom into a consuming project.

Options:
  --destination DIR  destination directory (default: vendor/bashloom)
  --force            replace an existing vendored copy
  -h, --help         show this help
EOF
}

while (($#)); do
  case $1 in
    --destination)
      (($# >= 2)) || {
        printf 'Missing value for --destination\n' >&2
        exit 2
      }
      destination=$2
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for command_name in mkdir cp mv rm; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  }
done

parent=${destination%/*}
[[ $parent == "$destination" ]] && parent=.
staging="$parent/.bashloom-vendor.$$"

cleanup() {
  rm -rf -- "$staging"
}
trap cleanup EXIT INT TERM

if [[ -e $destination && $force -ne 1 ]]; then
  printf 'Destination already exists: %s\n' "$destination" >&2
  printf 'Use --force to replace it.\n' >&2
  exit 1
fi

mkdir -p -- "$parent"
rm -rf -- "$staging"
cp -R -- "$REPO_ROOT/src" "$staging"

[[ -f $staging/bashloom.sh && -f $staging/bashloom-loader.sh ]] || {
  printf 'Vendored Bashloom runtime is incomplete.\n' >&2
  exit 1
}

if [[ -e $destination ]]; then
  rm -rf -- "$destination"
fi
mv -- "$staging" "$destination"
trap - EXIT INT TERM

printf 'Bashloom vendored at: %s\n' "$destination"
printf 'Use: source "%s/bashloom.sh"\n' "$destination"
