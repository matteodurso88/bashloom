#!/usr/bin/env bash

# Rollback stack for explicit transactional shell workflows.

_BLM_ROLLBACK_STACK=()
_BLM_ROLLBACK_NEXT_ID=0
_BLM_TRANSACTION_ACTIVE=0

blm_rollback_add() {
  (($# > 0)) || {
    blm_error "blm_rollback_add requires a command"
    return 2
  }

  local id=$_BLM_ROLLBACK_NEXT_ID
  local name="_BLM_ROLLBACK_CMD_${id}"
  declare -g -a "$name"
  local -n command_ref="$name"
  command_ref=("$@")

  _BLM_ROLLBACK_STACK+=("$name")
  _BLM_ROLLBACK_NEXT_ID=$((_BLM_ROLLBACK_NEXT_ID + 1))
}

blm_rollback_run() {
  local first_status=0
  local index name status

  for ((index = ${#_BLM_ROLLBACK_STACK[@]} - 1; index >= 0; index--)); do
    name=${_BLM_ROLLBACK_STACK[$index]}
    local -n command_ref="$name"

    if ((${#command_ref[@]} > 0)); then
      if "${command_ref[@]}"; then
        status=0
      else
        status=$?
      fi
      if ((status != 0 && first_status == 0)); then
        first_status=$status
      fi
    fi

    unset "$name"
  done

  _BLM_ROLLBACK_STACK=()
  _BLM_TRANSACTION_ACTIVE=0
  return "$first_status"
}

blm_rollback_clear() {
  local name
  for name in "${_BLM_ROLLBACK_STACK[@]}"; do
    unset "$name"
  done
  _BLM_ROLLBACK_STACK=()
}

blm_transaction_begin() {
  if ((_BLM_TRANSACTION_ACTIVE == 1)); then
    blm_error "A Bashloom transaction is already active"
    return 1
  fi

  blm_rollback_clear
  _BLM_TRANSACTION_ACTIVE=1
}

blm_transaction_commit() {
  if ((_BLM_TRANSACTION_ACTIVE == 0)); then
    blm_error "No Bashloom transaction is active"
    return 1
  fi

  blm_rollback_clear
  _BLM_TRANSACTION_ACTIVE=0
}

blm_transaction_rollback() {
  if ((_BLM_TRANSACTION_ACTIVE == 0)); then
    blm_error "No Bashloom transaction is active"
    return 1
  fi

  blm_rollback_run
}
