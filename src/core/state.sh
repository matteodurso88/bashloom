#!/usr/bin/env bash

# Small persistent state files using the same safe key=value data model as config.
#
# State is intentionally boring text: one literal value per key, no shell
# expansion and no implicit code execution. Mutations are delegated to
# blm_atomic_write so failed producers cannot partially overwrite prior state.

# Internal helper: reject physical line breaks because the state format stores
# exactly one key/value record per line. Other characters remain literal.
_blm_state_value_valid() {
  [[ $1 != *$'\n'* && $1 != *$'\r'* ]]
}

# Internal producer for blm_atomic_write: render a complete state file with one
# key inserted/replaced. Existing comments, blank lines and unrelated records
# retain their original order. Duplicate target keys fail rendering.
_blm_state_render_set() {
  local file=$1
  local wanted=$2
  local replacement=$3
  local line key found=0

  if [[ -f $file ]]; then
    while IFS= read -r line || [[ -n $line ]]; do
      if [[ -z $line || $line == \#* ]]; then
        printf '%s\n' "$line"
        continue
      fi
      key=${line%%=*}
      if [[ $key == "$wanted" ]]; then
        ((found == 0)) || return 1
        printf '%s=%s\n' "$wanted" "$replacement"
        found=1
      else
        printf '%s\n' "$line"
      fi
    done <"$file"
  fi

  ((found)) || printf '%s=%s\n' "$wanted" "$replacement"
}

# Internal producer for blm_atomic_write: render the file while omitting every
# record whose key exactly matches the requested key. Validation happens before
# this producer is invoked, so malformed source records are not normalized.
_blm_state_render_delete() {
  local file=$1
  local wanted=$2
  local line key

  while IFS= read -r line || [[ -n $line ]]; do
    if [[ -z $line || $line == \#* ]]; then
      printf '%s\n' "$line"
      continue
    fi
    key=${line%%=*}
    [[ $key == "$wanted" ]] || printf '%s\n' "$line"
  done <"$file"
}

# Public API: blm_state_get
# Purpose: Read one persistent state value with optional missing-file fallback.
# Usage: blm_state_get <file> <key> [fallback]
# Returns:
#   0  State value/fallback was printed.
#   1  File/key missing without fallback, or underlying validation failed.
#   2  Invalid Bashloom arguments/key grammar.
# Output: Selected literal value followed by a newline.
# Side effects: Reads state only.
# Notes: Existing files delegate to blm_config_get, inheriting duplicate-key and
# literal-data semantics from the config parser.
blm_state_get() {
  (($# >= 2 && $# <= 3)) || return 2
  local file=$1
  local key=$2

  if [[ ! -f $file ]]; then
    if (($# == 3)); then
      printf '%s\n' "$3"
      return 0
    fi
    return 1
  fi

  blm_config_get "$@"
}

# Public API: blm_state_set
# Purpose: Atomically create or replace one literal key/value state record.
# Usage: blm_state_set <file> <key> <value>
# Returns:
#   0  Atomic replacement succeeded.
#   1  Existing state invalid or filesystem/producer operation failed.
#   2  Invalid arguments/key/value grammar.
# Output: Errors follow the normal Bashloom stderr contract.
# Side effects: Atomically replaces/creates the state file on success.
# Security: Values are data, never sourced/eval'd; embedded newlines are rejected.
blm_state_set() {
  (($# == 3)) || return 2
  local file=$1
  local key=$2
  local value=$3

  _blm_valid_data_key "$key" || {
    blm_error "Invalid state key: $key"
    return 2
  }
  _blm_state_value_valid "$value" || {
    blm_error "State values cannot contain newlines"
    return 2
  }

  if [[ -f $file ]]; then
    blm_config_validate "$file" || return $?
  fi

  blm_atomic_write "$file" _blm_state_render_set "$file" "$key" "$value"
}

# Public API: blm_state_delete
# Purpose: Atomically remove one exact key while preserving all other records.
# Usage: blm_state_delete <file> <key>
# Returns:
#   0  Key was removed, key/file was already absent, or rewrite succeeded.
#   1  Existing state validation/filesystem operation failed.
#   2  Invalid arguments/key grammar.
# Output: Errors follow normal Bashloom stderr behavior.
# Side effects: Replaces an existing state file atomically; absent files are no-op.
blm_state_delete() {
  (($# == 2)) || return 2
  local file=$1
  local key=$2

  _blm_valid_data_key "$key" || {
    blm_error "Invalid state key: $key"
    return 2
  }
  [[ -f $file ]] || return 0
  blm_config_validate "$file" || return $?

  blm_atomic_write "$file" _blm_state_render_delete "$file" "$key"
}
