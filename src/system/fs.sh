#!/usr/bin/env bash

# Idempotent filesystem helpers.

blm_ensure_dir() {
  local mode=""
  if [[ ${1:-} == --mode ]]; then
    (($# >= 3)) || return 2
    mode=$2
    shift 2
  fi
  (($# == 1)) || return 2

  local path=$1
  blm_require_command mkdir || return 1
  command mkdir -p -- "$path" || return $?

  if [[ -n $mode ]]; then
    blm_require_command chmod || return 1
    command chmod "$mode" -- "$path"
  fi
}

blm_ensure_symlink() {
  (($# == 2)) || return 2
  local target=$1
  local link=$2

  if [[ -L $link ]]; then
    [[ $(readlink -- "$link") == "$target" ]] && return 0
    blm_error "Symlink exists with a different target: $link"
    return 1
  fi

  if [[ -e $link ]]; then
    blm_error "Path exists and is not a symlink: $link"
    return 1
  fi

  blm_require_command ln || return 1
  command ln -s -- "$target" "$link"
}

blm_atomic_write() {
  (($# >= 2)) || {
    blm_error "Usage: blm_atomic_write <path> <producer-command> [args...]"
    return 2
  }

  local path=$1
  shift
  local directory
  directory=$(blm_path_dirname "$path") || return $?

  [[ -d $directory ]] || {
    blm_error "Destination directory does not exist: $directory"
    return 1
  }

  local tmp
  tmp=$(blm_temp_file "$directory") || return $?

  local status=0
  if "$@" >"$tmp"; then
    :
  else
    status=$?
    command rm -f -- "$tmp"
    return "$status"
  fi

  if [[ -e $path ]]; then
    blm_require_command chmod || {
      command rm -f -- "$tmp"
      return 1
    }
    command chmod --reference="$path" "$tmp" || {
      status=$?
      command rm -f -- "$tmp"
      return "$status"
    }
  fi

  blm_require_command mv || {
    command rm -f -- "$tmp"
    return 1
  }
  command mv -f -- "$tmp" "$path"
}
