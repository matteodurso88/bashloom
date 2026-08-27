#!/usr/bin/env bash

# Logging foundations with optional file persistence.

_blm_log_rank() {
  case $1 in
    debug) printf '10\n' ;;
    info) printf '20\n' ;;
    warn) printf '30\n' ;;
    error) printf '40\n' ;;
    *) return 1 ;;
  esac
}

blm_log() {
  (($# >= 2)) || return 2
  local level=${1,,}
  shift
  local message=$*
  local configured=${BLM_LOG_LEVEL:-info}
  configured=${configured,,}

  local current_rank configured_rank
  current_rank=$(_blm_log_rank "$level") || {
    blm_error "Invalid log level: $level"
    return 2
  }
  configured_rank=$(_blm_log_rank "$configured") || {
    blm_error "Invalid BLM_LOG_LEVEL: $configured"
    return 2
  }

  ((current_rank >= configured_rank)) || return 0

  case $level in
    debug | info) _blm_emit_status stdout "$level" "${level^^}" '\033[36m' "$message" ;;
    warn) _blm_emit_status stderr warn WARN '\033[33m' "$message" ;;
    error) _blm_emit_status stderr error ERROR '\033[31m' "$message" ;;
  esac || return $?

  if [[ -n ${BLM_LOG_FILE:-} ]]; then
    local timestamp
    printf -v timestamp '%(%Y-%m-%dT%H:%M:%S%z)T' -1
    printf '%s [%s] %s\n' "$timestamp" "${level^^}" "$message" >>"$BLM_LOG_FILE" || return $?
  fi
}
