#!/usr/bin/env bash

# Change tracking for idempotent operations.
#
# BLM_LAST_CHANGED describes the most recent tracked operation.
# BLM_CHANGED is an aggregate flag that remains set until explicitly reset.

BLM_LAST_CHANGED=${BLM_LAST_CHANGED:-0}
BLM_CHANGED=${BLM_CHANGED:-0}

_blm_change_begin() {
  BLM_LAST_CHANGED=0
}

_blm_change_mark() {
  BLM_LAST_CHANGED=1
  BLM_CHANGED=1
}

blm_change_reset() {
  BLM_LAST_CHANGED=0
  BLM_CHANGED=0
}

blm_last_changed() {
  [[ ${BLM_LAST_CHANGED:-0} == 1 ]]
}

blm_changed() {
  [[ ${BLM_CHANGED:-0} == 1 ]]
}
