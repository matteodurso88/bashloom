#!/usr/bin/env bash

# Secure temporary resource helpers.
# mktemp is required only when these helpers are invoked; sourcing Bashloom
# remains dependency-free.

blm_temp_file() {
  local directory=${1:-${TMPDIR:-/tmp}}

  blm_require_command mktemp || return 1
  [[ -d $directory ]] || {
    blm_error "Temporary directory does not exist: $directory"
    return 1
  }

  (
    umask 077
    command mktemp "${directory%/}/bashloom.XXXXXX"
  )
}

blm_temp_dir() {
  local directory=${1:-${TMPDIR:-/tmp}}

  blm_require_command mktemp || return 1
  [[ -d $directory ]] || {
    blm_error "Temporary directory does not exist: $directory"
    return 1
  }

  (
    umask 077
    command mktemp -d "${directory%/}/bashloom.XXXXXX"
  )
}
