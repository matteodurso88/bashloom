#!/usr/bin/env bash

# Isolated command deadline primitive.
#
# The wrapped command runs in a subshell/background child so Bashloom can signal
# it independently from the caller shell. Consequently shell functions executed
# through this API cannot propagate variable/cwd mutations back to the caller.
#
# Current scope is direct-child termination. Process-group/descendant hardening
# remains a separately tracked Linux hardening item and is not implied here.

# Public API: blm_timeout
# Purpose: Run one command and enforce TERM -> grace -> KILL after a deadline.
# Usage: blm_timeout [--timeout S] [--grace S] [--] <command> [args...]
# Defaults: timeout=30 seconds, grace=1 second.
# Returns:
#   exact wrapped-command status when it finishes before the deadline;
#   124 when Bashloom enforces the timeout;
#   2 for invalid options/values or missing command;
#   127 when required sleep support fails during normal deadline polling.
# Output:
#   Wrapped command output is inherited. A timeout emits one Bashloom error.
# Side effects:
#   Starts a child process and may send TERM/KILL to that direct child.
# Isolation:
#   The child clears inherited INT/TERM traps before running caller code so
#   Bashloom's own cleanup trap configuration is not accidentally reused there.
# Timing model: Bash SECONDS is used; polling resolution is one second.
blm_timeout() {
  local timeout=30
  local grace=1

  while (($# > 0)); do
    case $1 in
      --timeout)
        (($# >= 2)) || return 2
        timeout=$2
        shift 2
        ;;
      --grace)
        (($# >= 2)) || return 2
        grace=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        blm_error "Unknown blm_timeout option: $1"
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  _blm_is_nonnegative_integer "$timeout" || {
    blm_error "--timeout must be a non-negative integer"
    return 2
  }
  _blm_is_nonnegative_integer "$grace" || {
    blm_error "--grace must be a non-negative integer"
    return 2
  }
  (($# > 0)) || {
    blm_error "blm_timeout requires a command"
    return 2
  }

  # `sleep` is a call-time dependency only. It is not required merely to source
  # Bashloom, preserving the dependency-free runtime import contract.
  if ((timeout > 0 || grace > 0)); then
    blm_require_command sleep || return 127
  fi

  (
    trap - INT TERM
    "$@"
  ) &
  local pid=$!
  local started=$SECONDS

  while kill -0 "$pid" 2>/dev/null; do
    if ((SECONDS - started >= timeout)); then
      kill -TERM "$pid" 2>/dev/null || true

      if ((grace > 0)); then
        # Failure during grace sleeping does not prevent escalation; timeout has
        # already occurred and the priority is to complete termination safely.
        command sleep "$grace" || true
      fi

      if kill -0 "$pid" 2>/dev/null; then
        kill -KILL "$pid" 2>/dev/null || true
      fi

      # Reap the child regardless of signal-derived status; public timeout
      # semantics intentionally normalize this path to status 124.
      wait "$pid" 2>/dev/null || true
      blm_error "Command timed out after ${timeout}s"
      return 124
    fi

    command sleep 1 || {
      # A polling infrastructure failure must not orphan the managed child.
      kill -TERM "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 127
    }
  done

  local status
  if wait "$pid"; then
    status=0
  else
    status=$?
  fi

  return "$status"
}
