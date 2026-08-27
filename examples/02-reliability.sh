#!/usr/bin/env bash

# Bashloom example: reliability primitives (M2).
#
# Demonstrates retry, polling, timeout, cleanup and rollback without touching
# persistent system state.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

workdir=$(blm_temp_dir)
cleanup_workspace() { rm -rf -- "$workdir"; }
blm_cleanup_add cleanup_workspace
blm_cleanup_enable_traps

counter="$workdir/retry-counter"
printf '0\n' >"$counter"

flaky_command() {
  local value
  value=$(<"$counter")
  value=$((value + 1))
  printf '%s\n' "$value" >"$counter"
  printf 'Attempt %d\n' "$value"
  ((value >= 3))
}

blm_retry --attempts 5 --delay 0 --backoff 1 flaky_command

ready_file="$workdir/ready"
(
  sleep 1
  touch "$ready_file"
) >/dev/null 2>&1 &

service_ready() { [[ -f $ready_file ]]; }
blm_wait_for --timeout 5 --interval 1 service_ready

if blm_timeout --timeout 1 --grace 1 sleep 10; then
  blm_error "Timeout example unexpectedly succeeded"
  exit 1
else
  status=$?
  [[ $status -eq 124 ]]
fi

state="$workdir/state"
backup="$workdir/state.backup"
printf 'original\n' >"$state"
cp "$state" "$backup"
restore_state() { cp "$backup" "$state"; }

blm_transaction_begin
blm_rollback_add restore_state
printf 'modified\n' >"$state"
blm_transaction_rollback
[[ $(<"$state") == original ]]

blm_transaction_begin
blm_rollback_add restore_state
printf 'committed\n' >"$state"
blm_transaction_commit
[[ $(<"$state") == committed ]]

blm_cleanup_disable_traps
blm_cleanup_run
blm_success "M2 example completed"
