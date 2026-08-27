#!/usr/bin/env bash

# Execute a command in an isolated child process and stop it after a timeout.
# Shell functions therefore run in a subshell and cannot mutate caller state.

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
        command sleep "$grace" || true
      fi

      if kill -0 "$pid" 2>/dev/null; then
        kill -KILL "$pid" 2>/dev/null || true
      fi

      wait "$pid" 2>/dev/null || true
      blm_error "Command timed out after ${timeout}s"
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
