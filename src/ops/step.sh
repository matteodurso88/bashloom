#!/usr/bin/env bash

# Step lifecycle wrapper.
#
# A step adds presentation around blm_run without changing command semantics.
# The original status remains the return value even if the human-readable final
# record is an error message.

# Public API: blm_step
# Purpose: Announce, execute and summarize one command as a named operation.
# Usage: blm_step <label> <command> [args...]
# Returns:
#   exact wrapped-command status;
#   2 when label/command arguments are missing.
# Output:
#   informational start record followed by success/error completion record;
#   wrapped command stdout/stderr passes through blm_run unchanged.
# Side effects: Exactly those of the wrapped command.
# Errexit invariant: blm_run is called inside an if-condition so caller `set -e`
# cannot bypass status capture or the completion record.
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

  # Completion rendering must not replace the command's actual status.
  return "$status"
}
