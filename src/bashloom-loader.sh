#!/usr/bin/env bash

# Bashloom selective module loader.
#
# Source this file when a consumer does not need the complete runtime. Loading
# is explicit, idempotent and dependency-aware. Sourcing the loader itself does
# not load any public module or emit output.

_BLM_LOADER_ENTRY=${BASH_SOURCE[0]}
_BLM_LOADER_DIR=${_BLM_LOADER_ENTRY%/*}
[[ $_BLM_LOADER_DIR == "$_BLM_LOADER_ENTRY" ]] && _BLM_LOADER_DIR=.
_BLM_ROOT="$(cd -- "$_BLM_LOADER_DIR" && pwd)"
unset _BLM_LOADER_ENTRY _BLM_LOADER_DIR

_BLM_LOADED_MODULES=()

_blm_loader_error() {
  printf '[BASHLOOM LOADER] %s\n' "$*" >&2
}

_blm_module_loaded() {
  local wanted=$1
  local loaded
  for loaded in "${_BLM_LOADED_MODULES[@]}"; do
    [[ $loaded == "$wanted" ]] && return 0
  done
  return 1
}

_blm_mark_module_loaded() {
  _BLM_LOADED_MODULES+=("$1")
}

_blm_load_core() {
  _blm_module_loaded core && return 0
  source "$_BLM_ROOT/core/version.sh"
  source "$_BLM_ROOT/core/capabilities.sh"
  source "$_BLM_ROOT/core/validate.sh"
  source "$_BLM_ROOT/core/output.sh"
  source "$_BLM_ROOT/core/env.sh"
  _blm_mark_module_loaded core
}

_blm_load_status() {
  _blm_module_loaded status && return 0
  _blm_load_core || return $?
  source "$_BLM_ROOT/ui/status.sh"
  _blm_mark_module_loaded status
}

_blm_load_logging() {
  _blm_module_loaded logging && return 0
  _blm_load_status || return $?
  source "$_BLM_ROOT/core/log.sh"
  _blm_mark_module_loaded logging
}

_blm_load_requirements() {
  _blm_module_loaded requirements && return 0
  _blm_load_status || return $?
  source "$_BLM_ROOT/ops/require.sh"
  _blm_mark_module_loaded requirements
}

_blm_load_runtime() {
  _blm_module_loaded runtime && return 0
  _blm_load_requirements || return $?
  source "$_BLM_ROOT/ops/run.sh"
  source "$_BLM_ROOT/ops/step.sh"
  _blm_mark_module_loaded runtime
}

_blm_load_reliability() {
  _blm_module_loaded reliability && return 0
  _blm_load_runtime || return $?
  source "$_BLM_ROOT/ops/retry.sh"
  source "$_BLM_ROOT/ops/wait.sh"
  source "$_BLM_ROOT/ops/timeout.sh"
  source "$_BLM_ROOT/ops/cleanup.sh"
  source "$_BLM_ROOT/ops/rollback.sh"
  _blm_mark_module_loaded reliability
}

_blm_load_system() {
  _blm_module_loaded system && return 0
  _blm_load_requirements || return $?
  source "$_BLM_ROOT/system/path.sh"
  source "$_BLM_ROOT/system/temp.sh"
  source "$_BLM_ROOT/system/fs.sh"
  _blm_mark_module_loaded system
}

_blm_load_state() {
  _blm_module_loaded state && return 0
  _blm_load_system || return $?
  source "$_BLM_ROOT/core/config.sh"
  source "$_BLM_ROOT/core/state.sh"
  _blm_mark_module_loaded state
}

# Load one or more named Bashloom module groups.
#
# Public module names:
#   core status logging requirements runtime reliability system state all
blm_load() {
  (($# >= 1)) || {
    _blm_loader_error "Usage: blm_load <module> [module...]"
    return 2
  }

  local module
  for module in "$@"; do
    case $module in
      core) _blm_load_core || return $? ;;
      status) _blm_load_status || return $? ;;
      logging) _blm_load_logging || return $? ;;
      requirements) _blm_load_requirements || return $? ;;
      runtime) _blm_load_runtime || return $? ;;
      reliability) _blm_load_reliability || return $? ;;
      system) _blm_load_system || return $? ;;
      state) _blm_load_state || return $? ;;
      all)
        _blm_load_reliability || return $?
        _blm_load_system || return $?
        _blm_load_state || return $?
        _blm_load_logging || return $?
        ;;
      *)
        _blm_loader_error "Unknown module: $module"
        return 2
        ;;
    esac
  done
}
