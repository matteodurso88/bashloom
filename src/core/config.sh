#!/usr/bin/env bash

# Safe key=value configuration helpers.
# Files are parsed as data; they are never sourced or evaluated.

_blm_valid_data_key() {
  [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_.-]*$ ]]
}

blm_config_validate() {
  (($# == 1)) || return 2
  local file=$1
  blm_require_file "$file" || return 1

  local line key
  while IFS= read -r line || [[ -n $line ]]; do
    [[ -z $line || $line == \#* ]] && continue
    [[ $line == *=* ]] || {
      blm_error "Invalid config line: $line"
      return 1
    }
    key=${line%%=*}
    _blm_valid_data_key "$key" || {
      blm_error "Invalid config key: $key"
      return 1
    }
  done <"$file"
}

blm_config_get() {
  (($# >= 2 && $# <= 3)) || return 2
  local file=$1
  local wanted=$2
  local fallback=${3-}

  _blm_valid_data_key "$wanted" || {
    blm_error "Invalid config key: $wanted"
    return 2
  }
  blm_config_validate "$file" || return $?

  local line key value found=0 result=""
  while IFS= read -r line || [[ -n $line ]]; do
    [[ -z $line || $line == \#* ]] && continue
    key=${line%%=*}
    value=${line#*=}
    if [[ $key == "$wanted" ]]; then
      ((found == 0)) || {
        blm_error "Duplicate config key: $wanted"
        return 1
      }
      found=1
      result=$value
    fi
  done <"$file"

  if ((found)); then
    printf '%s\n' "$result"
  elif (($# == 3)); then
    printf '%s\n' "$fallback"
  else
    return 1
  fi
}

blm_config_has() {
  (($# == 2)) || return 2
  blm_config_get "$1" "$2" >/dev/null
}
