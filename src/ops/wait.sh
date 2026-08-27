#!/usr/bin/env bash

# Poll a command until success or timeout.

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
