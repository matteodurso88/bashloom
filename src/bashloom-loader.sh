#!/usr/bin/env bash

# Bashloom selective module loader.
#
# This file is itself source-safe: importing it resolves Bashloom's own source
# root and defines loader functions, but does not load runtime modules, emit
# output, install traps or require external utilities.

_BLM_LOADER_ENTRY=${BASH_SOURCE[0]}
_BLM_LOADER_DIR=${_BLM_LOADER_ENTRY%/*}
[[ $_BLM_LOADER_DIR == "$_BLM_LOADER_ENTRY" ]] && _BLM_LOADER_DIR=.
_BLM_ROOT="$(cd -- "$_BLM_LOADER_DIR" && pwd)"
unset _BLM_LOADER_ENTRY _BLM_LOADER_DIR

_BLM_LOADED_MODULES=()

_blm_loader_error() { printf '[BASHLOOM LOADER] %s\n' "$*" >&2; }
_blm_source_module_file() {
  # shellcheck disable=SC1090
  source "$1"
}
_blm_module_loaded() {
  local wanted=$1 loaded
  for loaded in "${_BLM_LOADED_MODULES[@]}"; do [[ $loaded == "$wanted" ]] && return 0; done
  return 1
}
_blm_mark_module_loaded() { _BLM_LOADED_MODULES+=("$1"); }

_blm_load_core() {
  _blm_module_loaded core && return 0
  _blm_source_module_file "$_BLM_ROOT/core/version.sh"
  _blm_source_module_file "$_BLM_ROOT/core/capabilities.sh"
  _blm_source_module_file "$_BLM_ROOT/core/validate.sh"
  _blm_source_module_file "$_BLM_ROOT/core/change.sh"
  _blm_source_module_file "$_BLM_ROOT/core/output.sh"
  _blm_source_module_file "$_BLM_ROOT/core/env.sh"
  _blm_source_module_file "$_BLM_ROOT/core/diagnostics.sh"
  _blm_mark_module_loaded core
}
_blm_load_status() {
  _blm_module_loaded status && return 0
  _blm_load_core || return $?
  _blm_source_module_file "$_BLM_ROOT/ui/status.sh"
  _blm_source_module_file "$_BLM_ROOT/ui/error.sh"
  _blm_source_module_file "$_BLM_ROOT/ui/presentation.sh"
  _blm_mark_module_loaded status
}
_blm_load_terminal() {
  _blm_module_loaded terminal && return 0
  _blm_load_status || return $?
  _blm_source_module_file "$_BLM_ROOT/ui/prompt.sh"
  _blm_source_module_file "$_BLM_ROOT/ui/render.sh"
  _blm_source_module_file "$_BLM_ROOT/ui/progress.sh"
  _blm_mark_module_loaded terminal
}
_blm_load_logging() {
  _blm_module_loaded logging && return 0
  _blm_load_status || return $?
  _blm_source_module_file "$_BLM_ROOT/core/log.sh"
  _blm_mark_module_loaded logging
}
_blm_load_requirements() {
  _blm_module_loaded requirements && return 0
  _blm_load_status || return $?
  _blm_source_module_file "$_BLM_ROOT/ops/require.sh"
  _blm_mark_module_loaded requirements
}
_blm_load_runtime() {
  _blm_module_loaded runtime && return 0
  _blm_load_requirements || return $?
  _blm_source_module_file "$_BLM_ROOT/ops/run.sh"
  _blm_source_module_file "$_BLM_ROOT/ops/step.sh"
  _blm_mark_module_loaded runtime
}
_blm_load_reliability() {
  _blm_module_loaded reliability && return 0
  _blm_load_runtime || return $?
  _blm_source_module_file "$_BLM_ROOT/ops/retry.sh"
  _blm_source_module_file "$_BLM_ROOT/ops/wait.sh"
  _blm_source_module_file "$_BLM_ROOT/ops/timeout.sh"
  _blm_source_module_file "$_BLM_ROOT/ops/cleanup.sh"
  _blm_source_module_file "$_BLM_ROOT/ops/rollback.sh"
  _blm_mark_module_loaded reliability
}
_blm_load_system() {
  _blm_module_loaded system && return 0
  _blm_load_requirements || return $?
  _blm_source_module_file "$_BLM_ROOT/system/path.sh"
  _blm_source_module_file "$_BLM_ROOT/system/temp.sh"
  _blm_source_module_file "$_BLM_ROOT/system/fs.sh"
  _blm_source_module_file "$_BLM_ROOT/system/advanced-fs.sh"
  _blm_source_module_file "$_BLM_ROOT/system/lock.sh"
  _blm_source_module_file "$_BLM_ROOT/system/xdg.sh"
  _blm_mark_module_loaded system
}
_blm_load_state() {
  _blm_module_loaded state && return 0
  _blm_load_system || return $?
  _blm_source_module_file "$_BLM_ROOT/core/config.sh"
  _blm_source_module_file "$_BLM_ROOT/core/state.sh"
  _blm_mark_module_loaded state
}
_blm_load_git() {
  _blm_module_loaded git && return 0
  _blm_load_runtime || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/git.sh"
  _blm_mark_module_loaded git
}
_blm_load_systemd() {
  _blm_module_loaded systemd && return 0
  _blm_load_reliability || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/systemd.sh"
  _blm_mark_module_loaded systemd
}
_blm_load_docker() {
  _blm_module_loaded docker && return 0
  _blm_load_runtime || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/docker.sh"
  _blm_mark_module_loaded docker
}
_blm_load_network() {
  _blm_module_loaded network && return 0
  _blm_load_reliability || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/network.sh"
  _blm_mark_module_loaded network
}
_blm_load_integrations() {
  _blm_module_loaded integrations && return 0
  _blm_load_git || return $?
  _blm_load_systemd || return $?
  _blm_load_docker || return $?
  _blm_load_network || return $?
  _blm_mark_module_loaded integrations
}

# Public API: blm_load
# Purpose: Load one or more named Bashloom module groups into the caller shell.
# Usage: blm_load <module> [module...]
# Supported groups:
#   core status terminal logging requirements runtime reliability system state
#   git systemd docker network integrations all
# Returns: 0 on success, 2 for invalid/unknown groups, otherwise source failure.
# Output: Silent on success; bootstrap errors use loader stderr output.
# Side effects: Defines requested functions and updates _BLM_LOADED_MODULES.
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
      terminal) _blm_load_terminal || return $? ;;
      logging) _blm_load_logging || return $? ;;
      requirements) _blm_load_requirements || return $? ;;
      runtime) _blm_load_runtime || return $? ;;
      reliability) _blm_load_reliability || return $? ;;
      system) _blm_load_system || return $? ;;
      state) _blm_load_state || return $? ;;
      git) _blm_load_git || return $? ;;
      systemd) _blm_load_systemd || return $? ;;
      docker) _blm_load_docker || return $? ;;
      network) _blm_load_network || return $? ;;
      integrations) _blm_load_integrations || return $? ;;
      all)
        _blm_load_reliability || return $?
        _blm_load_system || return $?
        _blm_load_state || return $?
        _blm_load_logging || return $?
        _blm_load_terminal || return $?
        _blm_load_integrations || return $?
        ;;
      *)
        _blm_loader_error "Unknown module: $module"
        return 2
        ;;
    esac
  done
}
