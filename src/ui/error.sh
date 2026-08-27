#!/usr/bin/env bash

# Explicit error helpers.
#
# These functions deliberately return statuses instead of calling `exit`. A
# sourced library must not decide whether a caller should terminate, rollback,
# retry, convert the error, or continue with a degraded path.

# Public API: blm_fail
# Purpose: Render an error and return a caller-selected non-zero shell status.
# Usage: blm_fail <status> <message...>
# Arguments:
#   status  Integer in the shell-status range 1..255.
# Returns:
#   requested status after successful rendering;
#   2 for invalid Bashloom arguments/status;
#   rendering failure if blm_error itself fails.
# Output: One Bashloom error record to stderr, respecting BLM_OUTPUT_MODE.
# Side effects: None beyond stderr output; never exits the caller shell.
blm_fail() {
  (($# >= 2)) || return 2
  local status=$1
  shift

  [[ $status =~ ^[1-9][0-9]*$ ]] || {
    blm_error "Invalid failure status: $status"
    return 2
  }
  ((status <= 255)) || {
    blm_error "Invalid failure status: $status"
    return 2
  }

  # Rendering occurs before returning the requested status. If rendering itself
  # fails, preserving that failure is more truthful than masking it with status.
  blm_error "$@" || return $?
  return "$status"
}

# Public API: blm_usage_error
# Purpose: Report invalid caller usage using Bashloom's conventional status 2.
# Usage: blm_usage_error <message...>
# Returns: 2 after successful error rendering, or renderer failure.
# Output: One Bashloom error record to stderr.
# Side effects: None beyond output; does not terminate the process.
# Notes: Status 2 is reserved throughout Bashloom for invalid arguments/config.
blm_usage_error() {
  (($# >= 1)) || return 2
  blm_error "$@" || return $?
  return 2
}
