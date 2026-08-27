#!/usr/bin/env bash

# Polling primitive for readiness predicates and eventually-consistent systems.
#
# `blm_wait_for` is command-agnostic: success means only that the supplied
# command eventually returned zero. Domain-specific adapters (systemd, HTTP,
# etc.) can therefore reuse one timeout/status contract.

# Public API: blm_wait_for
# Purpose: Poll an argv-safe command until success or a wall-clock deadline.
# Usage: blm_wait_for [--timeout S] [--interval S] [--] <command> [args...]
# Defaults: timeout=30 seconds, interval=1 second.
# Returns:
#   0    Predicate succeeded before/at the deadline check.
#   124  Bashloom timeout status when deadline expires.
#   2    Invalid options/values or missing command.
#   127  Required sleep operation failed.
# Output:
#   Predicate output passes through; timeout emits an error containing the last
#   observed predicate status for diagnostics.
# Side effects: Repeated command execution plus optional sleep intervals.
# Timing model:
#   Bash's SECONDS variable is sampled, avoiding an external `date` dependency.
#   timeout=0 still performs one predicate attempt before deadline evaluation.
# Errexit invariant: predicate execution occurs through blm_run in an if branch.
blm_wait_for() {
  local timeout=30
  local interval=1

  while (($# > 0)); do
    case $1 in
      --timeout)
        (($# >= 2)) || return 2
        timeout=$2
        shift 2
        ;;
      --interval)
        (($# >= 2)) || return 2
        interval=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        blm_error "Unknown blm_wait_for option: $1"
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
  _blm_is_nonnegative_integer "$interval" || {
    blm_error "--interval must be a non-negative integer"
    return 2
  }
  (($# > 0)) || {
    blm_error "blm_wait_for requires a command"
    return 2
  }

  local started=$SECONDS
  local status=1

  while :; do
    if blm_run -- "$@"; then
      return 0
    else
      status=$?
    fi

    if ((SECONDS - started >= timeout)); then
      blm_error "Timed out after ${timeout}s waiting for command (last exit $status)"
      return 124
    fi

    if ((interval > 0)); then
      command sleep "$interval" || return 127
    fi
  done
}
