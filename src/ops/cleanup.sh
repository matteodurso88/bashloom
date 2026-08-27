#!/usr/bin/env bash

# Cleanup stack with safe argument preservation.
#
# Trap installation is explicit and refuses to overwrite existing traps.

_BLM_CLEANUP_STACK=()
_BLM_CLEANUP_NEXT_ID=0
_BLM_CLEANUP_RAN=0
_BLM_CLEANUP_TRAPS_ENABLED=0

blm_cleanup_add() {
  (($# > 0)) || {
    blm_error "blm_cleanup_add requires a command"
    return 2
  }

  local id=$_BLM_CLEANUP_NEXT_ID
  local name="_BLM_CLEANUP_CMD_${id}"
  declare -g -a "$name"
  local -n command_ref="$name"
  command_ref=("$@")

  _BLM_CLEANUP_STACK+=("$name")
  _BLM_CLEANUP_NEXT_ID=$((_BLM_CLEANUP_NEXT_ID + 1))
  _BLM_CLEANUP_RAN=0
}

blm_cleanup_run() {
  if ((_BLM_CLEANUP_RAN == 1)); then
    return 0
  fi

  _BLM_CLEANUP_RAN=1
  local first_status=0
  local index name status

  for ((index = ${#_BLM_CLEANUP_STACK[@]} - 1; index >= 0; index--)); do
    name=${_BLM_CLEANUP_STACK[$index]}
    local -n command_ref="$name"

    if ((${#command_ref[@]} > 0)); then
      "${command_ref[@]}"
      status=$?
      if ((status != 0 && first_status == 0)); then
        first_status=$status
      fi
    fi

    unset "$name"
  done

  _BLM_CLEANUP_STACK=()
  return "$first_status"
}

blm_cleanup_clear() {
  local name
  for name in "${_BLM_CLEANUP_STACK[@]}"; do
    unset "$name"
  done
  _BLM_CLEANUP_STACK=()
  _BLM_CLEANUP_RAN=0
}

_blm_cleanup_signal() {
  local signal=$1
  blm_cleanup_run
  local cleanup_status=$?

  trap - "$signal"
  if ((cleanup_status != 0)); then
    blm_warn "Cleanup completed with exit $cleanup_status before signal $signal"
  fi
  kill -s "$signal" "$$"
}

blm_cleanup_enable_traps() {
  if ((_BLM_CLEANUP_TRAPS_ENABLED == 1)); then
    return 0
  fi

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

blm_cleanup_disable_traps() {
  if ((_BLM_CLEANUP_TRAPS_ENABLED == 0)); then
    return 0
  fi

  trap - EXIT INT TERM
  _BLM_CLEANUP_TRAPS_ENABLED=0
}
