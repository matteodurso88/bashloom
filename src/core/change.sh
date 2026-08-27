#!/usr/bin/env bash

# Change tracking for idempotent operations.
#
# BLM_LAST_CHANGED describes the most recent tracked operation. BLM_CHANGED is
# aggregate run state and remains set until explicitly reset. Public predicates
# expose those variables without printing them, which makes them safe in both
# human and machine-readable output flows.

# Preserve caller-provided values when a consumer deliberately initializes the
# flags before sourcing Bashloom. Sourcing must not silently erase run state.
BLM_LAST_CHANGED=${BLM_LAST_CHANGED:-0}
BLM_CHANGED=${BLM_CHANGED:-0}

# Internal helper: begin a tracked operation by clearing only per-operation
# state. Aggregate state must survive until blm_change_reset is called.
_blm_change_begin() {
  BLM_LAST_CHANGED=0
}

# Internal helper: record that the current operation performed a mutation.
# Both flags are set together; subsequent no-op operations clear only the last
# flag through _blm_change_begin.
_blm_change_mark() {
  BLM_LAST_CHANGED=1
  BLM_CHANGED=1
}

# Public API: blm_change_reset
# Purpose: Start a fresh change-tracking scope for a caller-controlled run.
# Usage: blm_change_reset
# Returns: 0.
# Output: None.
# Side effects: Sets BLM_LAST_CHANGED=0 and BLM_CHANGED=0 in the caller shell.
blm_change_reset() {
  BLM_LAST_CHANGED=0
  BLM_CHANGED=0
}

# Public API: blm_last_changed
# Purpose: Test whether the most recent tracked operation changed the system.
# Usage: blm_last_changed
# Returns: 0 when BLM_LAST_CHANGED=1, otherwise 1.
# Output: None.
# Side effects: None.
blm_last_changed() {
  [[ ${BLM_LAST_CHANGED:-0} == 1 ]]
}

# Public API: blm_changed
# Purpose: Test whether any tracked operation changed the current run scope.
# Usage: blm_changed
# Returns: 0 when BLM_CHANGED=1, otherwise 1.
# Output: None.
# Side effects: None.
# Notes: The aggregate remains true across later no-op operations until reset.
blm_changed() {
  [[ ${BLM_CHANGED:-0} == 1 ]]
}
