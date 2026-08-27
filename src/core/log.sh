#!/usr/bin/env bash

# Logging foundations with optional file persistence.
#
# Logging is layered on the common status renderer so human/plain/JSON terminal
# output remains consistent. File persistence is deliberately a separate plain
# timestamped stream: log files should stay readable even when interactive
# output is configured as JSON.

# Internal helper: map symbolic levels to sortable integer severity ranks.
# Returning the rank through stdout keeps this helper pure and avoids global
# tables/state during sourcing.
_blm_log_rank() {
  case $1 in
    debug) printf '10\n' ;;
    info) printf '20\n' ;;
    warn) printf '30\n' ;;
    error) printf '40\n' ;;
    *) return 1 ;;
  esac
}

# Public API: blm_log
# Purpose: Emit a severity-filtered log record and optionally persist it.
# Usage: blm_log <debug|info|warn|error> <message...>
# Environment:
#   BLM_LOG_LEVEL  Minimum accepted severity; defaults to info.
#   BLM_LOG_FILE   Optional append-only destination for accepted records.
# Returns:
#   0  Record was filtered out or emitted/persisted successfully.
#   2  Invalid arguments, requested level, or configured log level.
#   other  Rendering or file-append failure.
# Output:
#   Accepted debug/info records use stdout; warn/error use stderr. Formatting
#   follows BLM_OUTPUT_MODE through _blm_emit_status.
# Side effects:
#   When BLM_LOG_FILE is non-empty, appends one timestamped line after terminal
#   rendering succeeds. The function never creates log files during sourcing.
# Ordering invariant: filtering occurs before output and persistence, so a
# filtered record has no visible or filesystem side effect.
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
    # Bash printf's time formatter avoids adding a `date` dependency to the
    # logging path. -1 selects the current time.
    printf -v timestamp '%(%Y-%m-%dT%H:%M:%S%z)T' -1
    printf '%s [%s] %s\n' "$timestamp" "${level^^}" "$message" >>"$BLM_LOG_FILE" || return $?
  fi
}
