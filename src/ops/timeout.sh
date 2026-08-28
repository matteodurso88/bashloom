#!/usr/bin/env bash

# Isolated command deadline primitive.
#
# External executables use GNU `timeout` when available. GNU timeout provides a
# mature Linux process-group implementation so deadline signals reach command
# descendants rather than only Bashloom's direct child. Shell functions and
# builtins retain Bashloom's direct-child backend because re-executing caller
# shell state through an external wrapper would change their semantics.
#
# All dependencies are checked only when blm_timeout is called; sourcing remains
# dependency-free and side-effect free.

_blm_timeout_gnu_available() {
  blm_has_command timeout || return 1
  local version
  version=$(command timeout --version 2>/dev/null || true)
  [[ $version == timeout\ \(GNU\ coreutils\)* ]]
}

_blm_timeout_direct() {
  (($# >= 3)) || return 2
  local timeout=$1 grace=$2
  shift 2

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
        command sleep "$grace" || true
      fi

      if kill -0 "$pid" 2>/dev/null; then
        kill -KILL "$pid" 2>/dev/null || true
      fi

      wait "$pid" 2>/dev/null || true
      return 124
    fi

    command sleep 1 || {
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

_blm_timeout_external() {
  (($# >= 3)) || return 2
  local timeout=$1 grace=$2
  shift 2

  # GNU timeout treats a zero duration as disabled, while Bashloom historically
  # defines timeout=0 as an immediate deadline. Preserve Bashloom semantics by
  # using the direct backend for that edge case.
  if ((timeout == 0)); then
    _blm_timeout_direct "$timeout" "$grace" "$@"
    return $?
  fi

  local kill_after=$grace
  # GNU `timeout -k 0` disables KILL escalation. Bashloom defines grace=0 as
  # immediate escalation, so use the smallest practical positive interval.
  ((grace == 0)) && kill_after=0.01

  local status
  if command timeout --signal=TERM --kill-after="${kill_after}s" "${timeout}s" "$@"; then
    status=0
  else
    status=$?
  fi

  # GNU timeout reports 124 for its normal deadline path. Some commands that
  # survive TERM until KILL can yield 137; normalize that enforced-kill path to
  # Bashloom's documented timeout status when the deadline has been delegated.
  if ((status == 124 || status == 137)); then
    return 124
  fi
  return "$status"
}

# Public API: blm_timeout
# Purpose: Run one command and enforce TERM -> grace -> KILL after a deadline.
# Usage: blm_timeout [--timeout S] [--grace S] [--] <command> [args...]
# Defaults: timeout=30 seconds, grace=1 second.
# Returns:
#   exact wrapped-command status when it finishes before the deadline;
#   124 when Bashloom enforces the timeout;
#   2 for invalid options/values or missing command;
#   127 when required sleep support fails in the Bash direct backend.
# Output: Wrapped output is inherited. An enforced timeout emits one error.
# Side effects: Starts child processes and may send TERM/KILL on deadline.
# External backend:
#   External executables use GNU coreutils `timeout` when available, gaining
#   process-group descendant termination. The dependency is call-time only.
# Compatibility backend:
#   Shell functions, builtins, timeout=0, or hosts without GNU timeout use the
#   direct-child Bash implementation and preserve caller shell semantics.
# Timing model: Bash fallback uses SECONDS with one-second polling resolution.
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
      *) break ;;
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

  if ((timeout > 0 || grace > 0)); then
    blm_require_command sleep || return 127
  fi

  local command_type status
  command_type=$(type -t -- "$1" 2>/dev/null || true)
  if [[ $command_type == file ]] && _blm_timeout_gnu_available; then
    if _blm_timeout_external "$timeout" "$grace" "$@"; then
      status=0
    else
      status=$?
    fi
  else
    if _blm_timeout_direct "$timeout" "$grace" "$@"; then
      status=0
    else
      status=$?
    fi
  fi

  if ((status == 124)); then
    blm_error "Command timed out after ${timeout}s"
  fi
  return "$status"
}
