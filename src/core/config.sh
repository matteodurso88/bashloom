#!/usr/bin/env bash

# Safe key=value configuration helpers.
#
# Configuration files are treated strictly as data. They are never sourced,
# evaluated or expanded as shell code. Values are preserved literally after the
# first `=` separator, including whitespace, quotes, `$()` text and extra `=`.

# Internal helper: validate the grammar accepted for data keys. The grammar is
# intentionally broader than shell variable names because dotted/dashed config
# keys are useful, while still excluding whitespace and control syntax.
_blm_valid_data_key() {
  [[ $1 =~ ^[A-Za-z_][A-Za-z0-9_.-]*$ ]]
}

# Public API: blm_config_validate
# Purpose: Validate the structural grammar of a literal key=value config file.
# Usage: blm_config_validate <file>
# Returns:
#   0  Every non-comment/non-blank line has a valid key and `=` separator.
#   1  File requirement or content validation failed.
#   2  Invalid Bashloom arguments.
# Output: Emits Bashloom error records to stderr on validation failures.
# Side effects: Reads the file only; no environment variables are created.
# Security: File contents are never executed or expanded.
blm_config_validate() {
  (($# == 1)) || return 2
  local file=$1
  blm_require_file "$file" || return 1

  local line key
  while IFS= read -r line || [[ -n $line ]]; do
    # A comment is recognized only when `#` is the first byte. Leading spaces
    # remain part of data and therefore fail key validation rather than being
    # silently normalized.
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

# Public API: blm_config_get
# Purpose: Read one literal value by exact key, optionally with a fallback.
# Usage: blm_config_get <file> <key> [fallback]
# Returns:
#   0  Key found, or fallback supplied for a missing key.
#   1  File invalid, key missing without fallback, or duplicate key detected.
#   2  Invalid Bashloom arguments/key grammar.
# Output: Writes exactly one selected/fallback value followed by a newline.
# Side effects: Reads the file only.
# Invariant: Duplicate matches are rejected instead of silently choosing first
# or last, because ambiguous configuration should fail deterministically.
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

# Public API: blm_config_has
# Purpose: Test whether a valid config file contains one exact key.
# Usage: blm_config_has <file> <key>
# Returns: Same success/failure semantics as blm_config_get without a fallback.
# Output: Suppressed; this helper is a predicate.
# Side effects: Reads/validates the file only.
blm_config_has() {
  (($# == 2)) || return 2
  blm_config_get "$1" "$2" >/dev/null
}
