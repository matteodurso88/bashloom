#!/usr/bin/env bash

# Bashloom example: runtime state primitives (M4).
#
# Demonstrates machine-readable output, logging, safe environment/config access
# and persistent state files without evaluating configuration as shell code.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

# shellcheck disable=SC2119
workdir=$(blm_temp_dir)
cleanup_workspace() { rm -rf -- "$workdir"; }
blm_cleanup_add cleanup_workspace
blm_cleanup_enable_traps

printf '%s\n' '--- Output modes ---'
BLM_OUTPUT_MODE=plain blm_info "plain output"
BLM_OUTPUT_MODE=json blm_info "machine-readable output"
BLM_OUTPUT_MODE=json blm_kv component runtime-state

printf '%s\n' '--- Environment ---'
export BASHLOOM_EXAMPLE_NAME="Bashloom"
printf 'name=%s\n' "$(blm_env_get BASHLOOM_EXAMPLE_NAME)"
printf 'fallback=%s\n' "$(blm_env_get BASHLOOM_EXAMPLE_MISSING default-value)"
export BASHLOOM_EXAMPLE_ENABLED=yes
if blm_env_bool BASHLOOM_EXAMPLE_ENABLED; then
  printf 'enabled=true\n'
fi

printf '%s\n' '--- Safe config ---'
config="$workdir/app.conf"
# SC2016 is intentional: the command substitution text is config data and must
# remain literal to demonstrate that Bashloom never evaluates it.
# shellcheck disable=SC2016
printf '%s\n' \
  '# Parsed as data, never sourced.' \
  'APP_NAME=Bashloom' \
  'COMMAND=$(printf unsafe)' >"$config"
blm_config_validate "$config"
printf 'APP_NAME=%s\n' "$(blm_config_get "$config" APP_NAME)"
printf 'COMMAND literal=%s\n' "$(blm_config_get "$config" COMMAND)"

printf '%s\n' '--- Persistent state ---'
state="$workdir/state.env"
blm_state_set "$state" phase bootstrap
blm_state_set "$state" attempts 1
printf 'phase=%s\n' "$(blm_state_get "$state" phase)"
blm_state_set "$state" phase ready
printf 'phase=%s\n' "$(blm_state_get "$state" phase)"
blm_state_delete "$state" attempts
printf 'attempts=%s\n' "$(blm_state_get "$state" attempts missing)"

printf '%s\n' '--- Logging ---'
log_file="$workdir/bashloom.log"
BLM_OUTPUT_MODE=plain BLM_LOG_LEVEL=debug BLM_LOG_FILE="$log_file" \
  blm_log debug "debug record"
BLM_OUTPUT_MODE=json BLM_LOG_LEVEL=info BLM_LOG_FILE="$log_file" \
  blm_log info "service ready"
printf '%s\n' 'Log file:'
cat "$log_file"

blm_cleanup_disable_traps
blm_cleanup_run
blm_success "M4 example completed"
