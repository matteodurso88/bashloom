#!/usr/bin/env bash

# Environment access helpers that never eval or source caller data.

_blm_valid_env_name() {
  [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]
}

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

blm_env_bool() {
  (($# >= 1 && $# <= 2)) || return 2
  local name=$1
  local fallback=${2-}
  local value

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
