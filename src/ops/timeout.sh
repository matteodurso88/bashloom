#!/usr/bin/env bash

# Isolated command deadline primitive.
#
# The wrapped command runs in a subshell/background child so Bashloom can signal
# it independently from the caller shell. Consequently shell functions executed
# through this API cannot propagate variable/cwd mutations back to the caller.
#
# On Linux-like hosts with `setsid`, external commands are started in a separate
# process group so timeout escalation reaches descendants as well as the direct
# child. Shell functions/builtins retain the compatible direct-child fallback
# because re-executing them through a new shell would break caller semantics.

_blm_timeout_target_alive() {
  (($# == 2)) || return 2
  local pid=$1 grouped=$2
  if ((grouped)); then
    kill -0 -- "-$pid" 2>/dev/null
  else
    kill -0 "$pid" 2>/dev/null
  fi
}

_blm_timeout_signal() {
  (($# == 3)) || return 2
  local signal=$1 pid=$2 grouped=$3
  if ((grouped)); then
    kill "-$signal" -- "-$pid" 2>/dev/null
  else
    kill "-$signal" "$pid" 2>/dev/null
  fi
}

# Public API: blm_timeout
# Purpose: Run one command and enforce TERM -> grace -> KILL after a deadline.
# Usage: blm_timeout [--timeout S] [--grace S] [--] <command> [args...]
# Defaults: timeout=30 seconds, grace=1 second.
# Returns:
#   exact wrapped-command status when it finishes before the deadline;
#   124 when Bashloom enforces the timeout;
#   2 for invalid options/values or missing command;
#   127 when required sleep support fails during normal deadline polling.
# Output: Wrapped output is inherited. A timeout emits one Bashloom error.
# Side effects: Starts a child and may send TERM/KILL to it or its process group.
# Isolation:
#   Direct-child fallback clears inherited INT/TERM traps before caller code.
# Process groups:
#   When the command resolves as an external executable and `setsid` is
#   available, Bashloom creates a new session/process group and signals the
#   group on timeout. Functions/builtins use the direct-child compatibility path.
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

  local grouped=0 command_type
  command_type=$(type -t -- "$1" 2>/dev/null || true)
  if [[ $command_type == file ]] && blm_has_command setsid; then
    command setsid -- "$@" &
    grouped=1
  else
    (
      trap - INT TERM
      "$@"
    ) &
  fi

  local pid=$!
  local started=$SECONDS

  while _blm_timeout_target_alive "$pid" "$grouped"; do
    if ((SECONDS - started >= timeout)); then
      _blm_timeout_signal TERM "$pid" "$grouped" || true

      if ((grace > 0)); then
        command sleep "$grace" || true
      fi

      if _blm_timeout_target_alive "$pid" "$grouped"; then
        _blm_timeout_signal KILL "$pid" "$grouped" || true
      fi

      wait "$pid" 2>/dev/null || true
      blm_error "Command timed out after ${timeout}s"
      return 124
    fi

    command sleep 1 || {
      _blm_timeout_signal TERM "$pid" "$grouped" || true
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
