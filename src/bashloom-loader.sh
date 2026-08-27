#!/usr/bin/env bash

# Bashloom selective module loader.
#
# This file is itself source-safe: importing it resolves Bashloom's own source
# root and defines loader functions, but does not load runtime modules, emit
# output, install traps or require external utilities.
#
# Dependency model:
#   - public groups are loaded lazily;
#   - every group resolves its declared prerequisites before sourcing files;
#   - a group is marked loaded only after all of its files were sourced;
#   - repeated `blm_load` calls are therefore idempotent for loaded groups.

# Resolve the library root from BASH_SOURCE rather than from the caller's cwd.
# This is intentionally pure Bash except for `pwd`, which is a Bash builtin in
# normal environments and does not create a runtime feature dependency.
_BLM_LOADER_ENTRY=${BASH_SOURCE[0]}
_BLM_LOADER_DIR=${_BLM_LOADER_ENTRY%/*}
[[ $_BLM_LOADER_DIR == "$_BLM_LOADER_ENTRY" ]] && _BLM_LOADER_DIR=.
_BLM_ROOT="$(cd -- "$_BLM_LOADER_DIR" && pwd)"
unset _BLM_LOADER_ENTRY _BLM_LOADER_DIR

# Internal state: names of module groups successfully loaded in this shell.
_BLM_LOADED_MODULES=()

# Internal helper: emit loader bootstrap errors before status/output modules may
# exist. This intentionally does not depend on blm_error.
_blm_loader_error() {
  printf '[BASHLOOM LOADER] %s\n' "$*" >&2
}

# Internal helper: source one resolved Bashloom module file.
# The path is constructed dynamically from the loader root, so ShellCheck
# cannot statically follow it; SC1090 is disabled only at this exact boundary.
_blm_source_module_file() {
  # shellcheck disable=SC1090
  source "$1"
}

# Internal helper: return success when a public group is already loaded.
_blm_module_loaded() {
  local wanted=$1
  local loaded
  for loaded in "${_BLM_LOADED_MODULES[@]}"; do
    [[ $loaded == "$wanted" ]] && return 0
  done
  return 1
}

# Internal helper: mark a group loaded only after its complete source sequence
# has succeeded. This keeps retries meaningful after a partial source failure.
_blm_mark_module_loaded() {
  _BLM_LOADED_MODULES+=("$1")
}

# Internal group loader: foundational metadata, validation and output helpers.
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

# Internal group loader: human/machine status, errors and presentation helpers.
_blm_load_status() {
  _blm_module_loaded status && return 0
  _blm_load_core || return $?
  _blm_source_module_file "$_BLM_ROOT/ui/status.sh"
  _blm_source_module_file "$_BLM_ROOT/ui/error.sh"
  _blm_source_module_file "$_BLM_ROOT/ui/presentation.sh"
  _blm_mark_module_loaded status
}

# Internal group loader: filtered logging layered on the status renderer.
_blm_load_logging() {
  _blm_module_loaded logging && return 0
  _blm_load_status || return $?
  _blm_source_module_file "$_BLM_ROOT/core/log.sh"
  _blm_mark_module_loaded logging
}

# Internal group loader: dependency/permission precondition helpers.
_blm_load_requirements() {
  _blm_module_loaded requirements && return 0
  _blm_load_status || return $?
  _blm_source_module_file "$_BLM_ROOT/ops/require.sh"
  _blm_mark_module_loaded requirements
}

# Internal group loader: command execution and step lifecycle primitives.
_blm_load_runtime() {
  _blm_module_loaded runtime && return 0
  _blm_load_requirements || return $?
  _blm_source_module_file "$_BLM_ROOT/ops/run.sh"
  _blm_source_module_file "$_BLM_ROOT/ops/step.sh"
  _blm_mark_module_loaded runtime
}

# Internal group loader: retry/wait/timeout plus cleanup/rollback stacks.
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

# Internal group loader: filesystem, locking and XDG system primitives.
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

# Internal group loader: literal configuration and persistent state files.
_blm_load_state() {
  _blm_module_loaded state && return 0
  _blm_load_system || return $?
  _blm_source_module_file "$_BLM_ROOT/core/config.sh"
  _blm_source_module_file "$_BLM_ROOT/core/state.sh"
  _blm_mark_module_loaded state
}

# Internal group loader: Git adapter. Runtime prerequisites provide standardized
# requirement/error helpers while the Git dependency remains call-time only.
_blm_load_git() {
  _blm_module_loaded git && return 0
  _blm_load_runtime || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/git.sh"
  _blm_mark_module_loaded git
}

# Internal group loader: systemd adapter. Reliability is required because the
# public wait helper delegates deadline behavior to blm_wait_for.
_blm_load_systemd() {
  _blm_module_loaded systemd && return 0
  _blm_load_reliability || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/systemd.sh"
  _blm_mark_module_loaded systemd
}

# Internal group loader: Docker/Compose adapter.
_blm_load_docker() {
  _blm_module_loaded docker && return 0
  _blm_load_runtime || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/docker.sh"
  _blm_mark_module_loaded docker
}

# Internal group loader: DNS and HTTP readiness checks. Reliability provides
# the shared polling/timeout implementation used by blm_wait_http.
_blm_load_network() {
  _blm_module_loaded network && return 0
  _blm_load_reliability || return $?
  _blm_source_module_file "$_BLM_ROOT/integrations/network.sh"
  _blm_mark_module_loaded network
}

# Internal aggregate loader: all currently shipped external-system adapters.
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
#   core status logging requirements runtime reliability system state
#   git systemd docker network integrations all
# Returns:
#   0  Every requested group loaded successfully or was already loaded.
#   2  No groups were supplied or an unknown group name was requested.
#   other  A source/dependency failure from the selected group's prerequisites.
# Output:
#   Silent on success. Bootstrap errors use a loader-specific stderr record.
# Side effects:
#   Defines the public/internal functions belonging to requested groups and
#   updates _BLM_LOADED_MODULES. It does not invoke feature-specific utilities.
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
        _blm_load_integrations || return $?
        ;;
      *)
        _blm_loader_error "Unknown module: $module"
        return 2
        ;;
    esac
  done
}
