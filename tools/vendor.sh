#!/usr/bin/env bash

# Vendor Bashloom into another project from a checked-out source tree.
#
# The generated consumer bundle is intentionally self-contained and records the
# exact upstream ref selected by the maintainer. Runtime deployment never needs
# network access and consumer code should treat the vendored src tree as
# immutable upstream material.

set -Eeuo pipefail

TOOL_DIR=${BASH_SOURCE[0]%/*}
[[ $TOOL_DIR == "${BASH_SOURCE[0]}" ]] && TOOL_DIR=.
REPO_ROOT="$(cd -- "$TOOL_DIR/.." && pwd)"

destination=vendor/bashloom
force=0
pin=

usage() {
  cat <<'EOF'
Usage: tools/vendor.sh [--destination DIR] [--pin REF] [--force]

Create a deterministic Bashloom consumer bundle containing:
  PIN
  LICENSE
  SHA256SUMS
  src/

Options:
  --destination DIR  destination directory (default: vendor/bashloom)
  --pin REF          explicit commit/tag metadata; defaults to current Git HEAD
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
    --pin)
      (($# >= 2)) || {
        printf 'Missing value for --pin\n' >&2
        exit 2
      }
      pin=$2
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

for command_name in mkdir cp mv rm find sort sha256sum; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  }
done

if [[ -z $pin ]]; then
  command -v git >/dev/null 2>&1 || {
    printf 'Cannot resolve vendor pin: git is unavailable; use --pin REF.\n' >&2
    exit 1
  }
  pin=$(git -C "$REPO_ROOT" rev-parse --verify HEAD 2>/dev/null) || {
    printf 'Cannot resolve vendor pin from Git HEAD; use --pin REF.\n' >&2
    exit 1
  }
fi

[[ -n $pin && $pin != *$'\n'* ]] || {
  printf 'Invalid vendor pin.\n' >&2
  exit 2
}

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

[[ -f $REPO_ROOT/LICENSE ]] || {
  printf 'Bashloom LICENSE not found.\n' >&2
  exit 1
}

mkdir -p -- "$parent"
rm -rf -- "$staging"
mkdir -p -- "$staging"
cp -R -- "$REPO_ROOT/src" "$staging/src"
cp -- "$REPO_ROOT/LICENSE" "$staging/LICENSE"
printf '%s\n' "$pin" >"$staging/PIN"

[[ -f $staging/src/bashloom.sh && -f $staging/src/bashloom-loader.sh ]] || {
  printf 'Vendored Bashloom runtime is incomplete.\n' >&2
  exit 1
}

(
  cd -- "$staging"
  {
    sha256sum LICENSE
    find src -type f -print | LC_ALL=C sort | while IFS= read -r path; do
      sha256sum "$path"
    done
  } >SHA256SUMS
)

if [[ -e $destination ]]; then
  rm -rf -- "$destination"
fi
mv -- "$staging" "$destination"
trap - EXIT INT TERM

printf 'Bashloom vendored at: %s\n' "$destination"
printf 'Pin: %s\n' "$pin"
printf 'Use: source "%s/src/bashloom.sh"\n' "$destination"
printf 'Verify: bash /path/to/bashloom/tools/vendor-verify.sh "%s"\n' "$destination"
