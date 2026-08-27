#!/usr/bin/env bash

# Runtime diagnostics for Bashloom consumers and CI environments.

blm_diagnostics() {
  (($# == 0)) || return 2

  local mode
  mode=$(_blm_output_mode) || return $?

  local tty=false
  local color=false
  local ci=false
  blm_is_tty && tty=true
  blm_color_enabled && color=true
  [[ -n ${CI:-} ]] && ci=true

  blm_kv bashloom_version "$BLM_VERSION" || return $?
  blm_kv bash_version "$BASH_VERSION" || return $?
  blm_kv output_mode "$mode" || return $?
  blm_kv tty "$tty" || return $?
  blm_kv color "$color" || return $?
  blm_kv ci "$ci"
}
