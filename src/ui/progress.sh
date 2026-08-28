#!/usr/bin/env bash

# Progress and spinner primitives with theme-aware TTY rendering.
#
# Human TTY mode supports stable visual variants. Plain/JSON/non-TTY execution
# remains deterministic for logs, pipes and CI. No third-party UI tool is used.

_blm_progress_bar() {
  (($# == 3)) || return 2
  local percent=$1 width=$2 style=$3 filled empty charset filled_glyph empty_glyph
  _blm_is_nonnegative_integer "$percent" || return 2
  _blm_is_positive_integer "$width" || return 2
  ((percent <= 100)) || return 2
  filled=$((percent * width / 100))
  empty=$((width - filled))
  charset=$(_blm_ui_effective_charset) || return $?

  case $style in
    blocks)
      if [[ $charset == unicode ]]; then
        filled_glyph='█'
        empty_glyph='░'
      else
        filled_glyph='#'
        empty_glyph='-'
      fi
      ;;
    bar)
      filled_glyph='='
      empty_glyph='-'
      ;;
    thin)
      if [[ $charset == unicode ]]; then
        filled_glyph='━'
        empty_glyph='─'
      else
        filled_glyph='='
        empty_glyph='-'
      fi
      ;;
    dots)
      if [[ $charset == unicode ]]; then
        filled_glyph='●'
        empty_glyph='·'
      else
        filled_glyph='o'
        empty_glyph='.'
      fi
      ;;
    percent) return 0 ;;
    *) return 2 ;;
  esac

  printf '%s%s' "$(_blm_repeat_glyph "$filled_glyph" "$filled")" "$(_blm_repeat_glyph "$empty_glyph" "$empty")"
}

# Public API: blm_progress
# Purpose: Render deterministic progress state with selectable TTY visual style.
# Usage: blm_progress [--style blocks|bar|thin|dots|percent] <current> <total> [label]
# Returns: 0 on success; 2 for invalid integers/current > total/UI policy.
# Output: Human TTY mode uses carriage-return rendering. Plain, JSON and non-TTY
#         modes emit one complete stable record per call.
# Side effects: None beyond stdout rendering.
# Configuration: BLM_PROGRESS_WIDTH defaults to 24 cells; BLM_PROGRESS_STYLE or
#                the active theme selects the default visual style.
# Invariant: Any valid render returns 0, including intermediate progress values.
blm_progress() {
  local style_override=''
  if (($# >= 1)) && [[ $1 == --style ]]; then
    (($# >= 4)) || return 2
    style_override=$2
    shift 2
  fi
  (($# >= 2 && $# <= 3)) || return 2
  _blm_is_nonnegative_integer "$1" || return 2
  _blm_is_positive_integer "$2" || return 2
  ((10#$1 <= 10#$2)) || return 2

  local current=$1 total=$2 label=${3:-progress} percent mode width style bar
  percent=$((10#$current * 100 / 10#$total))
  mode=$(_blm_output_mode) || return $?
  width=${BLM_PROGRESS_WIDTH:-24}
  _blm_is_positive_integer "$width" || return 2
  style=$(_blm_ui_resolve_style progress "$style_override") || return $?

  if [[ $mode == json ]]; then
    printf '{"type":"progress","label":"%s","current":%s,"total":%s,"percent":%s,"style":"%s"}\n' \
      "$(_blm_json_escape "$label")" "$current" "$total" "$percent" "$style"
  elif [[ $mode == human ]] && blm_is_tty; then
    if [[ $style == percent ]]; then
      printf '\r%s: %3d%% (%s/%s)' "$label" "$percent" "$current" "$total"
    else
      bar=$(_blm_progress_bar "$percent" "$width" "$style") || return $?
      printf '\r[%s] %3d%%  %s' "$bar" "$percent" "$label"
    fi
    if ((10#$current == 10#$total)); then printf '\n'; fi
  else
    printf '%s: %d%% (%s/%s)\n' "$label" "$percent" "$current" "$total"
  fi
  return 0
}

_blm_spinner_frames() {
  (($# == 2)) || return 2
  local style=$1 charset=$2
  case $style in
    braille)
      if [[ $charset == unicode ]]; then
        printf '%s\n' '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'
      else
        printf '%s\n' '|' '/' '-' "\\"
      fi
      ;;
    line) printf '%s\n' '|' '/' '-' "\\" ;;
    dots) printf '%s\n' '.  ' '.. ' '...' ;;
    pulse)
      if [[ $charset == unicode ]]; then printf '%s\n' '·' '•' '●' '•'; else printf '%s\n' '.' 'o' 'O' 'o'; fi
      ;;
    *) return 2 ;;
  esac
}

# Public API: blm_spinner
# Purpose: Run a command while displaying a selectable animated TTY spinner.
# Usage: blm_spinner [--style braille|line|dots|pulse] <label> <command> [args...]
# Returns: Exact wrapped command status; 2 for invalid arguments/UI policy.
# Output: Human TTY mode animates on stderr and finishes with a visual status.
#         Non-TTY/plain/json modes emit stable lifecycle records.
# Side effects: Starts the wrapped command in a direct child process and waits.
# Notes: This is not a timeout/process-group API.
blm_spinner() {
  local style_override=''
  if (($# >= 1)) && [[ $1 == --style ]]; then
    (($# >= 4)) || return 2
    style_override=$2
    shift 2
  fi
  (($# >= 2)) || return 2
  local label=$1
  shift
  local mode style
  mode=$(_blm_output_mode) || return $?
  style=$(_blm_ui_resolve_style spinner "$style_override") || return $?

  if [[ $mode != human ]] || ! blm_is_tty; then
    blm_info "$label"
    local stable_status
    if "$@"; then stable_status=0; else stable_status=$?; fi
    if ((stable_status == 0)); then blm_success "$label"; else blm_error "$label (exit $stable_status)"; fi
    return "$stable_status"
  fi

  local charset frame=0 status rendered_frame
  charset=$(_blm_ui_effective_charset) || return $?
  local -a frames=()
  mapfile -t frames < <(_blm_spinner_frames "$style" "$charset")
  ((${#frames[@]} > 0)) || return 2

  "$@" &
  local pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    rendered_frame=${frames[frame % ${#frames[@]}]}
    printf '\r%-3s %s' "$rendered_frame" "$label" >&2
    frame=$((frame + 1))
    command sleep 0.08 || true
  done

  if wait "$pid"; then status=0; else status=$?; fi

  if [[ $charset == unicode && ${BLM_UI_STYLE:-rich} == rich && ${BLM_UI_THEME:-default} != ascii && ${BLM_UI_THEME:-default} != ci ]]; then
    if ((status == 0)); then printf '\r✓ %s\033[K\n' "$label" >&2; else printf '\r✗ %s (exit %s)\033[K\n' "$label" "$status" >&2; fi
  elif ((status == 0)); then
    printf '\r[OK] %s\033[K\n' "$label" >&2
  else
    printf '\r[ERROR] %s (exit %s)\033[K\n' "$label" "$status" >&2
  fi
  return "$status"
}
