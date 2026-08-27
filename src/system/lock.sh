#!/usr/bin/env bash

# Dependency-light directory locking based on atomic mkdir.

blm_lock_acquire() {
  (($# == 1)) || return 2
  local lock_path=$1

  blm_require_command mkdir || return 1
  if command mkdir -- "$lock_path" 2>/dev/null; then
    return 0
  fi

  blm_error "Lock is already held: $lock_path"
  return 1
}

blm_lock_release() {
  (($# == 1)) || return 2
  local lock_path=$1

  [[ -d $lock_path ]] || {
    blm_error "Lock does not exist: $lock_path"
    return 1
  }

  blm_require_command rmdir || return 1
  command rmdir -- "$lock_path"
}

blm_with_lock() {
  (($# >= 2)) || {
    blm_error "Usage: blm_with_lock <lock-path> <command> [args...]"
    return 2
  }

  local lock_path=$1
  shift

  blm_lock_acquire "$lock_path" || return $?

  local status=0
  if "$@"; then
    :
  else
    status=$?
  fi

  local release_status=0
  if blm_lock_release "$lock_path"; then
    :
  else
    release_status=$?
  fi

  ((status != 0)) && return "$status"
  return "$release_status"
}
