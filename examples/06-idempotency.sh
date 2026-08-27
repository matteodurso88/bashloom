#!/usr/bin/env bash

# Bashloom example: idempotency and change tracking.
#
# Demonstrates how an automation can converge resources to a desired state and
# distinguish real changes from no-op re-runs.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

workdir=$(blm_temp_dir)
cleanup_workspace() { rm -rf -- "$workdir"; }
blm_cleanup_add cleanup_workspace
blm_cleanup_enable_traps

blm_change_reset

printf '%s\n' '--- First convergence pass ---'

blm_ensure_dir --mode 700 "$workdir/app"
printf 'directory changed=%s\n' "$BLM_LAST_CHANGED"

config="$workdir/app/app.conf"
blm_ensure_line "$config" 'enabled=true'
printf 'config line changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_line "$config" 'mode=production'
printf 'second config line changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_mode 600 "$config"
printf 'file mode changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_symlink "$config" "$workdir/current.conf"
printf 'symlink changed=%s\n' "$BLM_LAST_CHANGED"

if blm_changed; then
  printf 'first pass changed the system\n'
fi

printf '%s\n' '--- Second convergence pass ---'
blm_change_reset

blm_ensure_dir --mode 700 "$workdir/app"
printf 'directory changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_line "$config" 'enabled=true'
printf 'config line changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_line "$config" 'mode=production'
printf 'second config line changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_mode 600 "$config"
printf 'file mode changed=%s\n' "$BLM_LAST_CHANGED"

blm_ensure_symlink "$config" "$workdir/current.conf"
printf 'symlink changed=%s\n' "$BLM_LAST_CHANGED"

if blm_changed; then
  printf 'unexpected change during second pass\n' >&2
  exit 1
else
  printf 'second pass was a complete no-op\n'
fi

printf '%s\n' 'Final configuration:'
cat "$config"

blm_cleanup_disable_traps
blm_cleanup_run
blm_success "Idempotency example completed"
