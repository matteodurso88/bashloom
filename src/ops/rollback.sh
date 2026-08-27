#!/usr/bin/env bash

# Rollback stack for explicit transactional shell workflows.
#
# Rollback commands are compensating actions supplied by the caller and stored
# as argv arrays. Bashloom does not infer inverse operations automatically; this
# keeps transaction semantics explicit and domain-correct.

_BLM_ROLLBACK_STACK=()
_BLM_ROLLBACK_NEXT_ID=0
_BLM_TRANSACTION_ACTIVE=0

# Public API: blm_rollback_add
# Purpose: Register one compensating command for later LIFO rollback.
# Usage: blm_rollback_add <command> [args...]
# Returns: 0 on registration, 2 when no command is supplied.
# Output: Error record only for invalid usage.
# Side effects: Creates one internal global argv array and appends it to stack.
# Security: Original argv is preserved; no eval/string reconstruction.
blm_rollback_add() {
  (($# > 0)) || {
    blm_error "blm_rollback_add requires a command"
    return 2
  }

  local id=$_BLM_ROLLBACK_NEXT_ID
  local name="_BLM_ROLLBACK_CMD_${id}"
  declare -g -a "$name"
  # SC2178 is a false positive here: command_ref is intentionally a nameref
  # to a dynamically named array that preserves the original argv.
  # shellcheck disable=SC2178
  local -n command_ref="$name"
  command_ref=("$@")

  _BLM_ROLLBACK_STACK+=("$name")
  _BLM_ROLLBACK_NEXT_ID=$((_BLM_ROLLBACK_NEXT_ID + 1))
}

# Public API: blm_rollback_run
# Purpose: Execute all registered compensating actions in reverse order.
# Usage: blm_rollback_run
# Returns:
#   0 when all actions succeed or stack is empty;
#   first non-zero action status after still attempting all remaining actions.
# Output: Native rollback command output passes through.
# Side effects: Executes actions, clears stack and closes active transaction.
# Failure invariant: one rollback failure never short-circuits later actions.
blm_rollback_run() {
  local first_status=0
  local index name status

  for ((index = ${#_BLM_ROLLBACK_STACK[@]} - 1; index >= 0; index--)); do
    name=${_BLM_ROLLBACK_STACK[$index]}
    # See blm_rollback_add: this nameref targets an internal argv array.
    # shellcheck disable=SC2178
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

# Public API: blm_rollback_clear
# Purpose: Discard registered rollback actions without executing them.
# Usage: blm_rollback_clear
# Returns: 0.
# Output: None.
# Side effects: Unsets internal argv arrays and empties rollback stack.
# Notes: Transaction-active state is intentionally not changed by this low-level
# primitive; begin/commit own the transaction lifecycle explicitly.
blm_rollback_clear() {
  local name
  for name in "${_BLM_ROLLBACK_STACK[@]}"; do
    unset "$name"
  done
  _BLM_ROLLBACK_STACK=()
}

# Public API: blm_transaction_begin
# Purpose: Open one non-nestable transaction and discard stale rollback state.
# Usage: blm_transaction_begin
# Returns: 0 when opened; 1 if a transaction is already active.
# Output: Error on nested begin attempt.
# Side effects: Clears previous rollback stack and marks transaction active.
blm_transaction_begin() {
  if ((_BLM_TRANSACTION_ACTIVE == 1)); then
    blm_error "A Bashloom transaction is already active"
    return 1
  fi

  # Stale compensations from a prior non-transactional stack must not leak into
  # a fresh transaction boundary.
  blm_rollback_clear
  _BLM_TRANSACTION_ACTIVE=1
}

# Public API: blm_transaction_commit
# Purpose: Commit the active transaction by discarding compensating actions.
# Usage: blm_transaction_commit
# Returns: 0 when committed; 1 when no transaction is active.
# Output: Error for invalid lifecycle use.
# Side effects: Clears rollback stack and marks transaction inactive.
blm_transaction_commit() {
  if ((_BLM_TRANSACTION_ACTIVE == 0)); then
    blm_error "No Bashloom transaction is active"
    return 1
  fi

  blm_rollback_clear
  _BLM_TRANSACTION_ACTIVE=0
}

# Public API: blm_transaction_rollback
# Purpose: Roll back and close the currently active transaction.
# Usage: blm_transaction_rollback
# Returns: blm_rollback_run status; 1 when no transaction is active.
# Output: Error for invalid lifecycle use plus native rollback action output.
# Side effects: Executes compensating actions and closes transaction.
blm_transaction_rollback() {
  if ((_BLM_TRANSACTION_ACTIVE == 0)); then
    blm_error "No Bashloom transaction is active"
    return 1
  fi

  blm_rollback_run
}
