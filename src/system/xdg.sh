#!/usr/bin/env bash

# XDG Base Directory helpers for Linux-oriented consumers.

_blm_require_home() {
  [[ -n ${HOME:-} ]] || {
    blm_error "HOME is required for this XDG path"
    return 1
  }
}

blm_xdg_config_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_CONFIG_HOME:-} ]]; then
    printf '%s\n' "$XDG_CONFIG_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.config"
}

blm_xdg_data_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_DATA_HOME:-} ]]; then
    printf '%s\n' "$XDG_DATA_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.local/share"
}

blm_xdg_cache_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_CACHE_HOME:-} ]]; then
    printf '%s\n' "$XDG_CACHE_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.cache"
}

blm_xdg_state_home() {
  (($# == 0)) || return 2
  if [[ -n ${XDG_STATE_HOME:-} ]]; then
    printf '%s\n' "$XDG_STATE_HOME"
    return 0
  fi
  _blm_require_home || return $?
  printf '%s\n' "$HOME/.local/state"
}

blm_xdg_runtime_dir() {
  (($# == 0)) || return 2
  [[ -n ${XDG_RUNTIME_DIR:-} ]] || {
    blm_error "XDG_RUNTIME_DIR is not set"
    return 1
  }
  printf '%s\n' "$XDG_RUNTIME_DIR"
}
