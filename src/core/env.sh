#!/usr/bin/env bash

# Environment access helpers that never eval or source caller data.
#
# Indirect expansion is used only after validating the requested variable name.
# This prevents arbitrary parameter syntax from being interpreted as part of an
# environment lookup while still preserving exact variable values.

# Internal helper: accept only normal shell environment-variable identifiers.
_blm_valid_env_name() {
  [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

# Public API: blm_env_get
# Purpose: Read one environment variable by validated name with optional fallback.
# Usage: blm_env_get <NAME> [fallback]
# Returns:
#   0  Variable exists, or fallback was supplied for an unset variable.
#   1  Variable is unset and no fallback was supplied.
#   2  Invalid Bashloom arguments/name.
# Output: Writes the selected literal value followed by a newline.
# Side effects: None.
# Security: NAME is validated before `${!name}` indirect expansion is used.
blm_env_get() {
  (($# >= 1 && $# <= 2)) || return 2
  local name=$1
  local fallback=${2-}

  _blm_valid_env_name "$name" || {
    blm_error "Invalid environment variable name: $name"
    return 2
  }

  if [[ -v $name ]]; then
    printf '%s\n' "${!name}"
  elif (($# == 2)); then
    printf '%s\n' "$fallback"
  else
    return 1
  fi
}

# Public API: blm_env_bool
# Purpose: Interpret a validated environment variable as a boolean predicate.
# Usage: blm_env_bool <NAME> [fallback]
# Accepted true values: 1, true, yes, on (case-insensitive).
# Accepted false values: 0, false, no, off (case-insensitive).
# Returns:
#   0  Resolved value is true.
#   1  Resolved value is false, or variable is unset with no fallback.
#   2  Invalid arguments/name or a present value is not a recognized boolean.
# Output: No stdout output; invalid booleans emit a Bashloom error to stderr.
# Side effects: None.
# Notes: Status 1 intentionally represents both a valid false predicate and an
# absent value without fallback; callers that need to distinguish those cases
# should call blm_env_get first.
blm_env_bool() {
  (($# >= 1 && $# <= 2)) || return 2
  local name=$1
  local fallback=${2-}
  local value

  _blm_valid_env_name "$name" || {
    blm_error "Invalid environment variable name: $name"
    return 2
  }

  if [[ -v $name ]]; then
    value=${!name}
  elif (($# == 2)); then
    value=$fallback
  else
    return 1
  fi

  case ${value,,} in
    1 | true | yes | on)
      return 0
      ;;
    0 | false | no | off)
      return 1
      ;;
    *)
      blm_error "Environment variable is not boolean: $name"
      return 2
      ;;
  esac
}
