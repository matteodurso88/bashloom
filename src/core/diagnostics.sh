#!/usr/bin/env bash

# Runtime diagnostics for Bashloom consumers and CI environments.
#
# Diagnostics intentionally reuse the public key/value renderer so the same
# probe can be consumed by a person (`human`/`plain`) or automation (`json`)
# without maintaining a second output format.

# Public API: blm_diagnostics
# Purpose: Emit a compact snapshot of Bashloom/runtime output capabilities.
# Usage: blm_diagnostics
# Output keys:
#   bashloom_version  Current BLM_VERSION metadata.
#   bash_version      Bash runtime version string.
#   output_mode       Resolved human/plain/json mode.
#   tty               Whether stdout is a TTY.
#   color             Whether Bashloom would currently emit ANSI color.
#   ci                Whether CI is represented by a non-empty environment var.
# Returns:
#   0  Every diagnostic record rendered successfully.
#   2  Invalid arguments or invalid output-mode configuration.
#   other  Rendering failure propagated from blm_kv.
# Side effects: None beyond writing diagnostic records to stdout.
blm_diagnostics() {
  (($# == 0)) || return 2

  # Resolve mode once so all records describe one coherent snapshot even if a
  # caller were to mutate BLM_OUTPUT_MODE from a signal/trap during rendering.
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
