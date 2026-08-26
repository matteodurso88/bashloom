#!/usr/bin/env bash

# Render a status message to stdout or stderr without changing caller state.
#
# Usage: _blm_status <stream> <label> <ansi-color> <message...>
_blm_status() {
  local stream="$1"
  local label="$2"
  local color="$3"
  shift 3

  local prefix="[$label]"
  local reset='\033[0m'
  local fd=1

  [[ "$stream" == "stderr" ]] && fd=2

  if blm_color_enabled; then
    printf '%b%s%b %s\n' "$color" "$prefix" "$reset" "$*" >&"$fd"
  else
    printf '%s %s\n' "$prefix" "$*" >&"$fd"
  fi
}

# Print an informational status line.
blm_info() {
  _blm_status stdout "INFO" '\033[36m' "$@"
}

# Print a success status line.
blm_success() {
  _blm_status stdout "OK" '\033[32m' "$@"
}

# Print a warning status line to stderr.
blm_warn() {
  _blm_status stderr "WARN" '\033[33m' "$@"
}

# Print an error status line to stderr.
blm_error() {
  _blm_status stderr "ERROR" '\033[31m' "$@"
}
