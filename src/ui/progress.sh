#!/usr/bin/env bash

# Progress primitives with rich TTY rendering and deterministic degradation.
#
# Human TTY mode uses transient visual feedback. Plain/JSON/non-TTY execution
# remains stable for logs, pipes and CI. No third-party terminal UI tool is used.

# Internal helper: build one fixed-width progress bar in pure Bash.
_blm_progress_bar() {
  (($# == 2)) || return 2
  local percent=$1 width=$2 filled empty
  _blm_is_nonnegative_integer "$percent" || return 2
  _blm_is_positive_integer "$width" || return 2
  ((percent <= 100)) || return 2
  filled=$((percent * width / 100))
  empty=$((width - filled))

  local charset
  charset=$(_blm_ui_charset) || return $?
  if [[ $charset == unicode ]]; then
    printf '%s%s' "$(_blm_repeat_glyph '█' "$filled")" "$(_blm_repeat_glyph '░' "$empty")"
  else
    printf '%s%s' "$(_blm_repeat_glyph '#' "$filled")" "$(_blm_repeat_glyph '-' "$empty")"
  fi
}

# Public API: blm_progress
# Purpose: Render deterministic progress state, using a visual bar on human TTYs.
# Usage: blm_progress <current> <total> [label]
# Returns: 0 on success; 2 for invalid integers/current > total/UI policy.
# Output: Rich human TTY mode renders `[bar] NN% label` using carriage returns.
#         Plain, JSON and non-TTY modes emit one complete stable record per call.
# Side effects: None beyond stdout rendering.
# Configuration: BLM_PROGRESS_WIDTH may set a positive integer bar width;
#                default is 24 cells.
blm_progress() {
  (($# >= 2 && $# <= 3)) || return 2
  _blm_is_nonnegative_integer "$1" || return 2
  _blm_is_positive_integer "$2" || return 2
  ((10#$1 <= 10#$2)) || return 2

  local current=$1 total=$2 label=${3:-progress} percent mode width
  percent=$((10#$current * 100 / 10#$total))
  mode=$(_blm_output_mode) || return $?
  width=${BLM_PROGRESS_WIDTH:-24}
  _blm_is_positive_integer "$width" || return 2

  if [[ $mode == json ]]; then
    printf '{"type":"progress","label":"%s","current":%s,"total":%s,"percent":%s}\n' \
      "$(_blm_json_escape "$label")" "$current" "$total" "$percent"
  elif [[ $mode == human ]] && blm_is_tty && _blm_ui_rich_enabled; then
    local bar
    bar=$(_blm_progress_bar "$percent" "$width") || return $?
    printf '\r[%s] %3d%%  %s' "$bar" "$percent" "$label"
    ((10#$current == 10#$total)) && printf '\n'
  elif [[ $mode == human ]] && blm_is_tty; then
    printf '\r%s: %3d%% (%s/%s)' "$label" "$percent" "$current" "$total"
    ((10#$current == 10#$total)) && printf '\n'
  else
    printf '%s: %d%% (%s/%s)\n' "$label" "$percent" "$current" "$total"
  fi
}

# Public API: blm_spinner
# Purpose: Run a command while displaying an animated spinner on human TTYs.
# Usage: blm_spinner <label> <command> [args...]
# Returns: Exact wrapped command status; 2 for invalid arguments/UI policy.
# Output: Rich TTY mode animates on stderr and finishes with a visual success or
#         error marker. Non-TTY/plain/json modes emit stable lifecycle records.
# Side effects: Starts the wrapped command in a child process and waits for it.
# Notes: Tracks the direct child only; this is not a timeout/process-group API.
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
  local pid=$! frame=0 status charset frames
  charset=$(_blm_ui_charset) || return $?
  if [[ $charset == unicode && ${BLM_UI_STYLE:-rich} == rich ]]; then
    frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  else
    frames="|/-\\"
  fi

  local frame_count=${#frames}
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r%s %s' "${frames:frame%frame_count:1}" "$label" >&2
    frame=$((frame + 1))
    command sleep 0.08 || true
  done

  if wait "$pid"; then
    status=0
  else
    status=$?
  fi

  if [[ $charset == unicode && ${BLM_UI_STYLE:-rich} == rich ]]; then
    if ((status == 0)); then
      printf '\r✓ %s\n' "$label" >&2
    else
      printf '\r✗ %s (exit %s)\n' "$label" "$status" >&2
    fi
  elif ((status == 0)); then
    printf '\r[OK] %s\n' "$label" >&2
  else
    printf '\r[ERROR] %s (exit %s)\n' "$label" "$status" >&2
  fi
  return "$status"
}
