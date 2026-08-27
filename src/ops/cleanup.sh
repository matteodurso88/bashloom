#!/usr/bin/env bash

# Cleanup stack with safe argument preservation.
#
# Cleanup actions are stored as argv arrays rather than command strings, so no
# eval/re-parsing occurs when the stack is executed. Trap installation remains
# explicit and refuses to overwrite pre-existing caller traps.

# Internal runtime state:
#   _BLM_CLEANUP_STACK holds dynamically named argv arrays in registration order.
#   _BLM_CLEANUP_NEXT_ID ensures each array name is unique in the shell.
#   _BLM_CLEANUP_RAN makes one stack execution idempotent until new work/clear.
#   _BLM_CLEANUP_TRAPS_ENABLED tracks only traps installed by Bashloom itself.
_BLM_CLEANUP_STACK=()
_BLM_CLEANUP_NEXT_ID=0
_BLM_CLEANUP_RAN=0
_BLM_CLEANUP_TRAPS_ENABLED=0

# Public API: blm_cleanup_add
# Purpose: Register one cleanup command/argv for later LIFO execution.
# Usage: blm_cleanup_add <command> [args...]
# Returns: 0 on registration, 2 when no command is supplied.
# Output: Error record only for invalid usage.
# Side effects: Creates one internal global argv array and appends its name to
# the cleanup stack. Registering new work resets the "already ran" flag.
# Security: Original argv is preserved; no eval or command-string serialization.
blm_cleanup_add() {
  (($# > 0)) || {
    blm_error "blm_cleanup_add requires a command"
    return 2
  }

  local id=$_BLM_CLEANUP_NEXT_ID
  local name="_BLM_CLEANUP_CMD_${id}"
  declare -g -a "$name"
  # SC2178 is a false positive here: command_ref is intentionally a nameref
  # to a dynamically named array that preserves the original argv.
  # shellcheck disable=SC2178
  local -n command_ref="$name"
  command_ref=("$@")

  _BLM_CLEANUP_STACK+=("$name")
  _BLM_CLEANUP_NEXT_ID=$((_BLM_CLEANUP_NEXT_ID + 1))
  _BLM_CLEANUP_RAN=0
}

# Public API: blm_cleanup_run
# Purpose: Execute the current cleanup stack exactly once in reverse order.
# Usage: blm_cleanup_run
# Returns:
#   0 when every action succeeds or this stack was already run;
#   first non-zero cleanup status after still attempting all remaining actions.
# Output: Native cleanup command output is preserved.
# Side effects: Executes registered actions, unsets their argv arrays and clears
# the stack. The one-shot flag remains set until add/clear establishes new work.
# Failure invariant: one failing cleanup never prevents later LIFO actions.
blm_cleanup_run() {
  if ((_BLM_CLEANUP_RAN == 1)); then
    return 0
  fi

  _BLM_CLEANUP_RAN=1
  local first_status=0
  local index name status

  for ((index = ${#_BLM_CLEANUP_STACK[@]} - 1; index >= 0; index--)); do
    name=${_BLM_CLEANUP_STACK[$index]}
    # See blm_cleanup_add: this nameref targets an internal argv array.
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

  _BLM_CLEANUP_STACK=()
  return "$first_status"
}

# Public API: blm_cleanup_clear
# Purpose: Discard all registered cleanup actions without executing them.
# Usage: blm_cleanup_clear
# Returns: 0.
# Output: None.
# Side effects: Removes internal argv arrays, empties stack, resets run flag.
# Notes: Trap installation state is intentionally unaffected.
blm_cleanup_clear() {
  local name
  for name in "${_BLM_CLEANUP_STACK[@]}"; do
    unset "$name"
  done
  _BLM_CLEANUP_STACK=()
  _BLM_CLEANUP_RAN=0
}

# Internal signal handler: run cleanup, restore default disposition for the
# received signal, then re-signal this shell so externally visible termination
# semantics remain signal-derived rather than being converted to a normal exit.
_blm_cleanup_signal() {
  local signal=$1
  local cleanup_status
  if blm_cleanup_run; then
    cleanup_status=0
  else
    cleanup_status=$?
  fi

  trap - "$signal"
  if ((cleanup_status != 0)); then
    blm_warn "Cleanup completed with exit $cleanup_status before signal $signal"
  fi
  kill -s "$signal" "$$"
}

# Public API: blm_cleanup_enable_traps
# Purpose: Explicitly bind cleanup execution to EXIT, INT and TERM.
# Usage: blm_cleanup_enable_traps
# Returns: 0 when installed/already installed; 1 if any caller trap exists.
# Output: Error when Bashloom refuses to overwrite an existing trap.
# Side effects: Installs Bash traps only after confirming all three slots free.
# Source-safety: This function is never called automatically while sourcing.
blm_cleanup_enable_traps() {
  if ((_BLM_CLEANUP_TRAPS_ENABLED == 1)); then
    return 0
  fi

  # Check all signals first so trap installation is all-or-nothing rather than
  # leaving a partially installed Bashloom trap set after a conflict.
  local signal
  for signal in EXIT INT TERM; do
    if [[ -n $(trap -p "$signal") ]]; then
      blm_error "Refusing to overwrite existing $signal trap"
      return 1
    fi
  done

  trap 'blm_cleanup_run' EXIT
  trap '_blm_cleanup_signal INT' INT
  trap '_blm_cleanup_signal TERM' TERM
  _BLM_CLEANUP_TRAPS_ENABLED=1
}

# Public API: blm_cleanup_disable_traps
# Purpose: Remove only the trap set previously installed by Bashloom.
# Usage: blm_cleanup_disable_traps
# Returns: 0, including when traps were already disabled.
# Output: None.
# Side effects: Restores default EXIT/INT/TERM trap dispositions.
# Notes: Registered cleanup actions are preserved for explicit execution.
blm_cleanup_disable_traps() {
  if ((_BLM_CLEANUP_TRAPS_ENABLED == 0)); then
    return 0
  fi

  trap - EXIT INT TERM
  _BLM_CLEANUP_TRAPS_ENABLED=0
}
