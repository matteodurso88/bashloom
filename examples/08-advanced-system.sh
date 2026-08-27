#!/usr/bin/env bash

# Bashloom example: advanced Linux system primitives.
#
# Demonstrates safe copy/move/backup, SHA-256 checksums, directory locking,
# ownership convergence and XDG path resolution inside a temporary workspace.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

WORKDIR=$(blm_temp_dir)
trap 'rm -rf -- "$WORKDIR"' EXIT

blm_title "M6C — Advanced System"

blm_section "Safe filesystem operations"
printf 'payload\n' >"$WORKDIR/source"
blm_backup "$WORKDIR/source" "$WORKDIR/source.bak"
blm_safe_copy "$WORKDIR/source" "$WORKDIR/copied"
blm_safe_move "$WORKDIR/copied" "$WORKDIR/moved"
printf 'Checksum: %s\n' "$(blm_checksum_sha256 "$WORKDIR/moved")"

blm_section "Locking"
LOCK="$WORKDIR/demo.lock"
blm_with_lock "$LOCK" printf 'Protected operation executed.\n'

blm_section "Ownership convergence"
OWNER_GROUP=$(stat -c '%U:%G' "$WORKDIR/moved")
blm_ensure_owner "$OWNER_GROUP" "$WORKDIR/moved"
printf 'Current owner: %s\n' "$OWNER_GROUP"

blm_section "XDG paths"
printf 'Config: %s\n' "$(blm_xdg_config_home)"
printf 'Data:   %s\n' "$(blm_xdg_data_home)"
printf 'Cache:  %s\n' "$(blm_xdg_cache_home)"
printf 'State:  %s\n' "$(blm_xdg_state_home)"

if [[ -n ${XDG_RUNTIME_DIR:-} ]]; then
  printf 'Runtime: %s\n' "$(blm_xdg_runtime_dir)"
else
  printf 'Runtime: unavailable because XDG_RUNTIME_DIR is unset.\n'
fi

blm_success "Advanced system example completed"
