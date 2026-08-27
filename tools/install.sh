#!/usr/bin/env bash

# Install Bashloom from a checked-out source tree into a local prefix.
#
# Default destination:
#   $HOME/.local/lib/bashloom
#
# No privilege escalation is attempted. System-wide installation can be
# requested explicitly with --prefix /usr/local and an external sudo invocation.

set -Eeuo pipefail

TOOL_DIR=${BASH_SOURCE[0]%/*}
[[ $TOOL_DIR == "${BASH_SOURCE[0]}" ]] && TOOL_DIR=.
REPO_ROOT="$(cd -- "$TOOL_DIR/.." && pwd)"

prefix=${BASHLOOM_PREFIX:-"$HOME/.local"}
force=0

usage() {
  cat <<'EOF'
Usage: tools/install.sh [--prefix DIR] [--force]

Install Bashloom under DIR/lib/bashloom.

Options:
  --prefix DIR  installation prefix (default: $HOME/.local)
  --force       replace an existing Bashloom installation
  -h, --help    show this help
EOF
}

while (($#)); do
  case $1 in
    --prefix)
      (($# >= 2)) || {
        printf 'Missing value for --prefix\n' >&2
        exit 2
      }
      prefix=$2
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

lib_dir="$prefix/lib"
destination="$lib_dir/bashloom"
staging="$lib_dir/.bashloom-install.$$"

cleanup() {
  rm -rf -- "$staging"
}
trap cleanup EXIT INT TERM

if [[ -e $destination && $force -ne 1 ]]; then
  printf 'Bashloom already exists: %s\n' "$destination" >&2
  printf 'Use --force to replace it.\n' >&2
  exit 1
fi

mkdir -p -- "$lib_dir"
rm -rf -- "$staging"
cp -R -- "$REPO_ROOT/src" "$staging"

[[ -f $staging/bashloom.sh && -f $staging/bashloom-loader.sh ]] || {
  printf 'Staged Bashloom runtime is incomplete.\n' >&2
  exit 1
}

if [[ -e $destination ]]; then
  rm -rf -- "$destination"
fi
mv -- "$staging" "$destination"
trap - EXIT INT TERM

printf 'Bashloom installed at: %s\n' "$destination"
printf 'Full runtime: source "%s/bashloom.sh"\n' "$destination"
printf 'Selective loader: source "%s/bashloom-loader.sh"\n' "$destination"
