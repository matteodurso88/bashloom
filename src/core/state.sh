#!/usr/bin/env bash

# Small persistent state files using the same safe key=value data model as config.

_blm_state_value_valid() {
  [[ $1 != *$'\n'* && $1 != *$'\r'* ]]
}

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
