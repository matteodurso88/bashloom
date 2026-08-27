#!/usr/bin/env bash

# Retry a command without changing the caller's shell options.
#
# Retry owns only repetition timing. It does not classify failures as transient
# versus permanent; the caller chooses the command/predicate whose non-zero
# statuses are eligible for retry.

# Public API: blm_retry
# Purpose: Execute an argv-safe command repeatedly until success or exhaustion.
# Usage: blm_retry [--attempts N] [--delay S] [--backoff N] [--] <command> [args...]
# Defaults: attempts=3, delay=1 second, integer backoff multiplier=1.
# Returns:
#   0    Command succeeded within the attempt budget.
#   final wrapped-command status when all attempts fail.
#   2    Invalid Bashloom options/values or missing command.
#   127  Required sleep operation failed when a delay was needed.
# Output:
#   Wrapped command output passes through; a warning is emitted between failed
#   attempts but never after the final failed attempt.
# Side effects: Repeats the wrapped command and may sleep between invocations.
# Errexit invariant: each command runs through blm_run inside an if-condition.
# Timing invariant: delay is applied only between attempts; backoff multiplies
# the next delay after each sleep and is restricted to positive integers.
blm_retry() {
  local attempts=3
  local delay=1
  local backoff=1

  while (($# > 0)); do
    case $1 in
      --attempts)
        (($# >= 2)) || return 2
        attempts=$2
        shift 2
        ;;
      --delay)
        (($# >= 2)) || return 2
        delay=$2
        shift 2
        ;;
      --backoff)
        (($# >= 2)) || return 2
        backoff=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        blm_error "Unknown blm_retry option: $1"
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  _blm_is_positive_integer "$attempts" || {
    blm_error "--attempts must be a positive integer"
    return 2
  }
  _blm_is_nonnegative_integer "$delay" || {
    blm_error "--delay must be a non-negative integer"
    return 2
  }
  _blm_is_positive_integer "$backoff" || {
    blm_error "--backoff must be a positive integer"
    return 2
  }
  (($# > 0)) || {
    blm_error "blm_retry requires a command"
    return 2
  }

  local attempt=1
  local status=0
  local current_delay=$delay

  while ((attempt <= attempts)); do
    if blm_run -- "$@"; then
      return 0
    else
      status=$?
    fi

    if ((attempt == attempts)); then
      return "$status"
    fi

    blm_warn "Attempt $attempt/$attempts failed with exit $status; retrying in ${current_delay}s"
    if ((current_delay > 0)); then
      # `sleep` is required only when the configured delay is non-zero; this
      # preserves feature-specific dependency use in zero-delay test/CI flows.
      command sleep "$current_delay" || return 127
    fi

    current_delay=$((current_delay * backoff))
    ((attempt++))
  done

  return "$status"
}
