#!/usr/bin/env bash

# Explicit error helpers. These functions never exit the caller shell.

blm_fail() {
  (($# >= 2)) || return 2
  local status=$1
  shift

  [[ $status =~ ^[1-9][0-9]*$ ]] || {
    blm_error "Invalid failure status: $status"
    return 2
  }
  ((status <= 255)) || {
    blm_error "Invalid failure status: $status"
    return 2
  }

  blm_error "$@" || return $?
  return "$status"
}

blm_usage_error() {
  (($# >= 1)) || return 2
  blm_error "$@" || return $?
  return 2
}
