#!/usr/bin/env bash

# XDG Base Directory helpers for Linux-oriented consumers.
#
# These functions calculate paths only; they never create directories. Standard
# XDG fallback paths are used for config/data/cache/state when HOME is available.
# XDG_RUNTIME_DIR is different: Bashloom refuses to invent a runtime directory
# because security/ownership/lifecycle guarantees belong to the session manager.

# Internal helper: require HOME before constructing an XDG fallback.
_blm_require_home() {
  [[ -n ${HOME:-} ]] || {
    blm_error "HOME is required for this XDG path"
    return 1
  }
}

# Public API: blm_xdg_config_home
# Purpose: Print effective per-user configuration base directory.
# Usage: blm_xdg_config_home
# Returns: 0 with explicit/default path, 1 if fallback needs missing HOME, 2 args.
# Output: XDG_CONFIG_HOME or `$HOME/.config`.
# Side effects: None; directory is not created.
blm_xdg_config_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_CONFIG_HOME:-} ]]; then
    printf '%s\n' "$XDG_CONFIG_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.config"
}

# Public API: blm_xdg_data_home
# Purpose: Print effective per-user application data base directory.
# Usage: blm_xdg_data_home
# Returns: 0 with explicit/default path, 1 if HOME unavailable, 2 on arguments.
# Output: XDG_DATA_HOME or `$HOME/.local/share`.
# Side effects: None.
blm_xdg_data_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_DATA_HOME:-} ]]; then
    printf '%s\n' "$XDG_DATA_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.local/share"
}

# Public API: blm_xdg_cache_home
# Purpose: Print effective per-user non-essential cache base directory.
# Usage: blm_xdg_cache_home
# Returns: 0 with explicit/default path, 1 if HOME unavailable, 2 on arguments.
# Output: XDG_CACHE_HOME or `$HOME/.cache`.
# Side effects: None.
blm_xdg_cache_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_CACHE_HOME:-} ]]; then
    printf '%s\n' "$XDG_CACHE_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.cache"
}

# Public API: blm_xdg_state_home
# Purpose: Print effective per-user persistent state base directory.
# Usage: blm_xdg_state_home
# Returns: 0 with explicit/default path, 1 if HOME unavailable, 2 on arguments.
# Output: XDG_STATE_HOME or `$HOME/.local/state`.
# Side effects: None.
blm_xdg_state_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_STATE_HOME:-} ]]; then
    printf '%s\n' "$XDG_STATE_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.local/state"
}

# Public API: blm_xdg_runtime_dir
# Purpose: Print the session-provided runtime directory only when explicitly set.
# Usage: blm_xdg_runtime_dir
# Returns: 0 when XDG_RUNTIME_DIR is non-empty, 1 when absent, 2 on arguments.
# Output: Runtime path to stdout or Bashloom error to stderr.
# Side effects: None.
# Security invariant: No `/tmp` fallback is synthesized because XDG runtime dirs
# require ownership, mode and lifecycle guarantees Bashloom cannot safely infer.
blm_xdg_runtime_dir() {
  (($# == 0)) || return 2
  [[ -n ${XDG_RUNTIME_DIR:-} ]] || {
    blm_error "XDG_RUNTIME_DIR is not set"
    return 1
  }
  printf '%s\n' "$XDG_RUNTIME_DIR"
}
