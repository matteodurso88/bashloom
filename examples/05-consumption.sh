#!/usr/bin/env bash

# Bashloom example: consumption model (M5).
#
# Demonstrates selective loading, prefix installation, vendoring and release
# metadata validation. All writes stay inside a temporary workspace.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"

# Use Bashloom itself to allocate a safe workspace for the consumption demo.
source "$REPO_ROOT/src/bashloom.sh"
workdir=$(blm_temp_dir "${TMPDIR:-/tmp}")
cleanup_workspace() { rm -rf -- "$workdir"; }
blm_cleanup_add cleanup_workspace
blm_cleanup_enable_traps

printf '%s\n' '--- Selective module loading ---'
bash -c '
  set -Eeuo pipefail
  source "$1/src/bashloom-loader.sh"
  blm_load runtime system
  type blm_run >/dev/null 2>&1
  type blm_atomic_write >/dev/null 2>&1
  ! type blm_state_set >/dev/null 2>&1
  printf "Selective runtime loaded successfully.\n"
' _ "$REPO_ROOT"

printf '%s\n' '--- Prefix installation ---'
prefix="$workdir/prefix"
bash "$REPO_ROOT/tools/install.sh" --prefix "$prefix"
bash -c '
  set -Eeuo pipefail
  source "$1/lib/bashloom/bashloom.sh"
  printf "Installed version: %s\n" "$BLM_VERSION"
' _ "$prefix"

printf '%s\n' '--- Vendoring ---'
vendored="$workdir/project/vendor/bashloom"
bash "$REPO_ROOT/tools/vendor.sh" --destination "$vendored"
bash -c '
  set -Eeuo pipefail
  source "$1/bashloom-loader.sh"
  blm_load core
  printf "Vendored version: %s\n" "$BLM_VERSION"
' _ "$vendored"

printf '%s\n' '--- Release metadata gate ---'
bash "$REPO_ROOT/tools/release-check.sh" "$BLM_VERSION"

blm_cleanup_disable_traps
blm_cleanup_run
blm_success "M5 consumption example completed"
