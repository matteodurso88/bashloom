#!/usr/bin/env bash

# Human-readable step execution while preserving the wrapped command status.

blm_step() {
  if (($# < 2)); then
    blm_error "Usage: blm_step <label> <command> [args...]"
    return 2
  fi

  local label=$1
  shift

  blm_info "$label"

  local status
  if blm_run -- "$@"; then
    status=0
  else
    status=$?
  fi

  if ((status == 0)); then
    blm_success "$label"
  else
    blm_error "$label (exit $status)"
  fi

  return "$status"
}
