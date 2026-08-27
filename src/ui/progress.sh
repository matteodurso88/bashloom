#!/usr/bin/env bash

# Lightweight progress primitives with automatic non-TTY degradation.

# Public API: blm_progress
# Purpose: Render a deterministic progress record from current and total values.
# Usage: blm_progress <current> <total> [label]
# Returns: 0 on success; 2 for invalid integers or current > total.
# Output: Human TTY mode uses carriage-return updates until completion. Plain,
#         JSON and non-TTY human modes emit one complete line per call.
# Side effects: None beyond stdout rendering.
blm_progress() {
  (($# >= 2 && $# <= 3)) || return 2
  _blm_is_nonnegative_integer "$1" || return 2
  _blm_is_positive_integer "$2" || return 2
  ((10#$1 <= 10#$2)) || return 2

  local current=$1 total=$2 label=${3:-progress} percent mode
  percent=$((10#$current * 100 / 10#$total))
  mode=$(_blm_output_mode) || return $?

  if [[ $mode == json ]]; then
    printf '{"type":"progress","label":"%s","current":%s,"total":%s,"percent":%s}\n' \
      "$(_blm_json_escape "$label")" "$current" "$total" "$percent"
  elif [[ $mode == human ]] && blm_is_tty; then
    printf '\r%s: %3d%% (%s/%s)' "$label" "$percent" "$current" "$total"
    ((10#$current == 10#$total)) && printf '\n'
  else
    printf '%s: %d%% (%s/%s)\n' "$label" "$percent" "$current" "$total"
  fi
}

# Public API: blm_spinner
# Purpose: Run a command while displaying a transient spinner on interactive
#          human terminals and a stable lifecycle message elsewhere.
# Usage: blm_spinner <label> <command> [args...]
# Returns: Exact wrapped command status; 2 for invalid arguments.
# Output: TTY human mode animates on stderr; non-TTY/plain/json modes emit start
#         and final status records through Bashloom's normal renderer.
# Side effects: Starts the wrapped command in a child process and waits for it.
# Notes: The spinner intentionally tracks only the direct child; it is not a
#        timeout or process-group management primitive.
blm_spinner() {
  (($# >= 2)) || return 2
  local label=$1
  shift
  local mode
  mode=$(_blm_output_mode) || return $?

  if [[ $mode != human ]] || ! blm_is_tty; then
    blm_info "$label"
    local status
    if "$@"; then
      status=0
    else
      status=$?
    fi
    if ((status == 0)); then
      blm_success "$label"
    else
      blm_error "$label (exit $status)"
    fi
    return "$status"
  fi

  "$@" &
  local pid=$! frame=0 frames="|/-\\"
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r[%s] %s' "${frames:frame%4:1}" "$label" >&2
    frame=$((frame + 1))
    command sleep 0.1 || true
  done

  local status
  if wait "$pid"; then
    status=0
  else
    status=$?
  fi
  if ((status == 0)); then
    printf '\r[OK] %s\n' "$label" >&2
  else
    printf '\r[ERROR] %s (exit %s)\n' "$label" "$status" >&2
  fi
  return "$status"
}
