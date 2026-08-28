#!/usr/bin/env bash

# Dependency-free full-screen TUI primitives.
#
# The TUI layer is explicit: sourcing never changes terminal state and no traps
# are installed automatically. blm_tui_run is the preferred lifecycle wrapper
# because it guarantees screen/cursor restoration while preserving command
# status. Lower-level enter/leave calls are available for advanced callers.

_BLM_TUI_ACTIVE=${_BLM_TUI_ACTIVE:-0}

_blm_tui_capable() {
  [[ $(_blm_output_mode) == human ]] || return 1
  blm_is_tty || return 1
  [[ ${TERM:-} != dumb ]] || return 1
  return 0
}

# Public API: blm_tui_available
# Purpose: Report whether the current process can use Bashloom full-screen TUI.
# Usage: blm_tui_available
# Returns: 0 when interactive TUI is usable; 1 otherwise; 2 for arguments.
# Output: None.
# Side effects: None.
blm_tui_available() {
  (($# == 0)) || return 2
  _blm_tui_capable
}

# Public API: blm_tui_enter
# Purpose: Enter the alternate screen and hide the cursor for full-screen UI.
# Usage: blm_tui_enter
# Returns: 0 on success; 1 when no suitable interactive TTY exists; 2 for args.
# Output: ANSI terminal control sequences to stdout.
# Side effects: Changes terminal presentation until blm_tui_leave is called.
blm_tui_enter() {
  (($# == 0)) || return 2
  _blm_tui_capable || return 1
  ((_BLM_TUI_ACTIVE == 0)) || return 0
  printf '\033[?1049h\033[?25l\033[2J\033[H'
  _BLM_TUI_ACTIVE=1
}

# Public API: blm_tui_leave
# Purpose: Restore cursor visibility and leave the alternate screen.
# Usage: blm_tui_leave
# Returns: 0 on success; 2 for args.
# Output: ANSI terminal control sequences when a TUI is active.
# Side effects: Restores presentation state changed by blm_tui_enter.
blm_tui_leave() {
  (($# == 0)) || return 2
  ((_BLM_TUI_ACTIVE == 1)) || return 0
  printf '\033[?25h\033[?1049l'
  _BLM_TUI_ACTIVE=0
}

# Public API: blm_tui_clear
# Purpose: Clear the current full-screen TUI frame and move to home position.
# Usage: blm_tui_clear
# Returns: 0 when active; 1 when no TUI is active; 2 for args.
# Output: ANSI clear/home sequence.
# Side effects: Clears the active terminal screen buffer.
blm_tui_clear() {
  (($# == 0)) || return 2
  ((_BLM_TUI_ACTIVE == 1)) || return 1
  printf '\033[2J\033[H'
}

# Public API: blm_tui_move
# Purpose: Move the TUI cursor to a 1-based row and column.
# Usage: blm_tui_move <row> <column>
# Returns: 0 on success; 1 when inactive; 2 for invalid coordinates.
# Output: ANSI cursor-position sequence.
# Side effects: Moves terminal cursor.
blm_tui_move() {
  (($# == 2)) || return 2
  _blm_is_positive_integer "$1" || return 2
  _blm_is_positive_integer "$2" || return 2
  ((_BLM_TUI_ACTIVE == 1)) || return 1
  printf '\033[%s;%sH' "$1" "$2"
}

# Public API: blm_tui_size
# Purpose: Report the current terminal dimensions for resize-aware rendering.
# Usage: blm_tui_size
# Returns: 0 on success; 2 for args.
# Output: `<columns> <rows>` on stdout.
# Dependencies: Uses tput when available; otherwise COLUMNS/LINES and 80x24
#               deterministic fallbacks.
# Side effects: None.
blm_tui_size() {
  (($# == 0)) || return 2
  local columns=${BLM_TUI_COLUMNS:-${COLUMNS:-}} rows=${BLM_TUI_LINES:-${LINES:-}}

  if [[ -z $columns || -z $rows ]] && command -v tput >/dev/null 2>&1 && [[ ${TERM:-} != dumb ]]; then
    [[ -n $columns ]] || columns=$(tput cols 2>/dev/null || true)
    [[ -n $rows ]] || rows=$(tput lines 2>/dev/null || true)
  fi

  _blm_is_positive_integer "${columns:-}" || columns=80
  _blm_is_positive_integer "${rows:-}" || rows=24
  printf '%s %s\n' "$columns" "$rows"
}

# Public API: blm_tui_read_key
# Purpose: Read one normalized keyboard event from interactive stdin.
# Usage: blm_tui_read_key [timeout-seconds]
# Returns: 0 when a key was read; 1 on timeout/EOF; 2 for invalid arguments.
# Output: Printable key or one of UP/DOWN/LEFT/RIGHT/HOME/END/ESC/ENTER/TAB/
#         BACKSPACE on stdout.
# Side effects: Consumes bytes from stdin without echo.
blm_tui_read_key() {
  (($# <= 1)) || return 2
  [[ -t 0 ]] || return 1
  local timeout=${1:-} key rest read_status
  local -a read_args=(-rsn1)
  if [[ -n $timeout ]]; then
    [[ $timeout =~ ^[0-9]+([.][0-9]+)?$ ]] || return 2
    read_args+=(-t "$timeout")
  fi

  if IFS= read "${read_args[@]}" key; then
    read_status=0
  else
    read_status=$?
  fi
  ((read_status == 0)) || return 1

  case $key in
    '') printf '%s\n' ENTER ;;
    $'\t') printf '%s\n' TAB ;;
    $'\177' | $'\b') printf '%s\n' BACKSPACE ;;
    $'\e')
      rest=''
      IFS= read -rsn2 -t 0.02 rest || true
      case $rest in
        '[A') printf '%s\n' UP ;;
        '[B') printf '%s\n' DOWN ;;
        '[C') printf '%s\n' RIGHT ;;
        '[D') printf '%s\n' LEFT ;;
        '[H' | 'OH') printf '%s\n' HOME ;;
        '[F' | 'OF') printf '%s\n' END ;;
        *) printf '%s\n' ESC ;;
      esac
      ;;
    *) printf '%s\n' "$key" ;;
  esac
}

# Public API: blm_tui_run
# Purpose: Execute a command inside a managed alternate-screen TUI lifecycle.
# Usage: blm_tui_run <command> [args...]
# Returns: Exact wrapped command status; 1 if TUI is unavailable; 2 for args.
# Output: Wrapped command output plus terminal lifecycle sequences.
# Side effects: Enters and always leaves alternate screen around the command.
# Invariant: Does not install or overwrite caller traps.
blm_tui_run() {
  (($# >= 1)) || return 2
  blm_tui_enter || return $?
  local status
  if "$@"; then
    status=0
  else
    status=$?
  fi
  blm_tui_leave || true
  return "$status"
}
