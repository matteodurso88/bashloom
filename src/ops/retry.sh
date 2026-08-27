#!/usr/bin/env bash

# Retry a command without changing the caller's shell options.

_blm_is_nonnegative_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

_blm_is_positive_integer() {
  [[ $1 =~ ^[1-9][0-9]*$ ]]
}

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
    blm_run -- "$@"
    status=$?

    if ((status == 0)); then
      return 0
    fi

    if ((attempt == attempts)); then
      return "$status"
    fi

    blm_warn "Attempt $attempt/$attempts failed with exit $status; retrying in ${current_delay}s"
    if ((current_delay > 0)); then
      command sleep "$current_delay" || return 127
    fi

    current_delay=$((current_delay * backoff))
    ((attempt++))
  done

  return "$status"
}
