#!/usr/bin/env bash

# Bashloom full feature tour.
#
# This script is both a presentation/demo and a manual integration smoke test
# for every public primitive implemented through M4. It is intentionally
# non-destructive: all filesystem work happens inside a temporary directory.
#
# Run from the repository root:
#   bash examples/full-tour.sh

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

section() {
  printf '\n====================================================================\n'
  printf '%s\n' "$1"
  printf '====================================================================\n'
}

section "Runtime metadata and capabilities"
printf 'Bashloom version: %s\n' "$BLM_VERSION"
blm_has_command bash
if blm_is_tty; then
  printf 'stdout is a TTY\n'
else
  printf 'stdout is not a TTY\n'
fi
if blm_color_enabled; then
  printf 'color output is enabled\n'
else
  printf 'color output is disabled for this context\n'
fi
blm_info "information message"
blm_success "success message"
blm_warn "warning message"
blm_error "intentional demonstration error message"

section "Requirements"
export BASHLOOM_EXAMPLE_ENV=ready
blm_require_command bash
blm_require_env BASHLOOM_EXAMPLE_ENV
if blm_require_command __bashloom_example_missing_command__; then
  exit 1
else
  printf 'missing command correctly rejected\n'
fi
if blm_require_root; then
  printf 'running as root\n'
else
  printf 'running as non-root user\n'
fi

section "Temporary resources and cleanup"
workdir=$(blm_temp_dir "${TMPDIR:-/tmp}")
printf 'workspace: %s\n' "$workdir"
cleanup_workspace() { rm -rf -- "$workdir"; }
blm_cleanup_add cleanup_workspace
blm_cleanup_enable_traps

tmpfile=$(blm_temp_file "$workdir")
blm_require_file "$tmpfile"
blm_require_dir "$workdir"
blm_require_readable "$tmpfile"
blm_require_writable "$tmpfile"
blm_require_executable "$workdir"

section "Command runtime"
blm_run printf 'executed through blm_run\n'
if blm_run bash -c 'exit 42'; then
  exit 1
else
  status=$?
  printf 'preserved exit status: %d\n' "$status"
  [[ $status -eq 42 ]]
fi

marker="$workdir/dry-run-marker"
blm_run --dry-run touch "$marker"
[[ ! -e $marker ]]
BLM_DRY_RUN=1 blm_run touch "$marker"
[[ ! -e $marker ]]

blm_step "Create a file" touch "$workdir/step-file"
[[ -f $workdir/step-file ]]
if blm_step "Intentional failing step" bash -c 'exit 33'; then
  exit 1
else
  [[ $? -eq 33 ]]
fi

section "Retry and polling"
counter="$workdir/retry-counter"
printf '0\n' >"$counter"
flaky_command() {
  local value
  value=$(<"$counter")
  value=$((value + 1))
  printf '%s\n' "$value" >"$counter"
  printf 'attempt %d\n' "$value"
  ((value >= 3))
}
blm_retry --attempts 5 --delay 0 --backoff 1 flaky_command
[[ $(<"$counter") -eq 3 ]]

ready_file="$workdir/ready"
(
  sleep 1
  touch "$ready_file"
) >/dev/null 2>&1 &
service_ready() { [[ -f $ready_file ]]; }
blm_wait_for --timeout 5 --interval 1 service_ready

never_ready() { return 1; }
if blm_wait_for --timeout 1 --interval 1 never_ready; then
  exit 1
else
  [[ $? -eq 124 ]]
fi

section "Command timeout"
if blm_timeout --timeout 1 --grace 1 sleep 10; then
  exit 1
else
  [[ $? -eq 124 ]]
fi

section "Filesystem safety"
app_dir="$workdir/app/data"
blm_ensure_dir "$app_dir"
blm_ensure_dir "$app_dir"
blm_ensure_dir --mode 700 "$workdir/private"

real_file="$workdir/real.txt"
other_file="$workdir/other.txt"
link_file="$workdir/link.txt"
printf 'real\n' >"$real_file"
printf 'other\n' >"$other_file"
blm_ensure_symlink "$real_file" "$link_file"
blm_ensure_symlink "$real_file" "$link_file"
if blm_ensure_symlink "$other_file" "$link_file"; then
  exit 1
else
  printf 'conflicting symlink correctly rejected\n'
fi

config="$workdir/config.ini"
printf 'version=old\n' >"$config"
generate_config() {
  printf 'version=new\n'
  printf 'enabled=true\n'
}
blm_atomic_write "$config" generate_config
[[ $(<"$config") == $'version=new\nenabled=true' ]]

cp "$config" "$workdir/config-before-failure.ini"
failing_generator() {
  printf 'partial content that must not be installed\n'
  return 55
}
if blm_atomic_write "$config" failing_generator; then
  exit 1
else
  [[ $? -eq 55 ]]
  cmp -s "$config" "$workdir/config-before-failure.ini"
fi

section "Path helpers"
path=/var/lib/bashloom/config.ini
blm_path_is_absolute "$path"
printf 'dirname:  %s\n' "$(blm_path_dirname "$path")"
printf 'basename: %s\n' "$(blm_path_basename "$path")"
printf 'join:     %s\n' "$(blm_path_join /var lib bashloom config.ini)"
if blm_path_is_absolute relative/path; then
  exit 1
fi

section "Runtime state and machine output"
BLM_OUTPUT_MODE=plain blm_info "plain output"
BLM_OUTPUT_MODE=json blm_info "json output"
BLM_OUTPUT_MODE=json blm_kv phase M4
printf 'effective default output mode: %s\n' "$(blm_output_mode)"

export BASHLOOM_EXAMPLE_BOOL=yes
blm_env_bool BASHLOOM_EXAMPLE_BOOL
printf 'env fallback: %s\n' "$(blm_env_get BASHLOOM_EXAMPLE_MISSING fallback)"

runtime_config="$workdir/runtime.conf"
# SC2016 is intentional here: the command substitution text is literal config
# data and must not be expanded by the shell.
# shellcheck disable=SC2016
printf '%s\n' \
  '# literal data' \
  'APP=Bashloom' \
  'PAYLOAD=$(printf not-executed)' >"$runtime_config"
blm_config_validate "$runtime_config"
[[ $(blm_config_get "$runtime_config" APP) == Bashloom ]]
# shellcheck disable=SC2016
[[ $(blm_config_get "$runtime_config" PAYLOAD) == '$(printf not-executed)' ]]

runtime_state="$workdir/runtime.state"
blm_state_set "$runtime_state" phase bootstrap
blm_state_set "$runtime_state" phase ready
[[ $(blm_state_get "$runtime_state" phase) == ready ]]
blm_state_set "$runtime_state" attempts 1
blm_state_delete "$runtime_state" attempts
[[ $(blm_state_get "$runtime_state" attempts missing) == missing ]]

log_file="$workdir/bashloom.log"
BLM_OUTPUT_MODE=plain BLM_LOG_LEVEL=debug BLM_LOG_FILE="$log_file" \
  blm_log debug "debug record"
BLM_OUTPUT_MODE=json BLM_LOG_FILE="$log_file" \
  blm_log info "runtime ready"
[[ -s $log_file ]]

section "Rollback stack"
rollback_log="$workdir/rollback.log"
rollback_first() { printf 'first\n' >>"$rollback_log"; }
rollback_second() { printf 'second\n' >>"$rollback_log"; }
blm_rollback_add rollback_first
blm_rollback_add rollback_second
blm_rollback_run
[[ $(<"$rollback_log") == $'second\nfirst' ]]

section "Transactions"
transaction_state="$workdir/transaction-state"
backup="$workdir/transaction-state.backup"
printf 'original\n' >"$transaction_state"
cp "$transaction_state" "$backup"
restore_state() { cp "$backup" "$transaction_state"; }

blm_transaction_begin
blm_rollback_add restore_state
printf 'modified\n' >"$transaction_state"
blm_transaction_rollback
[[ $(<"$transaction_state") == original ]]

blm_transaction_begin
blm_rollback_add restore_state
printf 'committed\n' >"$transaction_state"
blm_transaction_commit
[[ $(<"$transaction_state") == committed ]]

section "Cleanup stack behavior"
cleanup_log="$workdir/cleanup.log"
cleanup_first() { printf 'first\n' >>"$cleanup_log"; }
cleanup_second() { printf 'second\n' >>"$cleanup_log"; }
blm_cleanup_add cleanup_first
blm_cleanup_add cleanup_second

# Keep the workspace cleanup registered underneath these two actions. Running
# the stack proves LIFO order and removes the workspace last.
blm_cleanup_disable_traps
blm_cleanup_run

printf '\nBashloom full tour completed successfully.\n'
