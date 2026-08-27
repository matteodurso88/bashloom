#!/usr/bin/env bash

# Idempotent filesystem helpers.

blm_ensure_dir() {
  _blm_change_begin

  local mode=""
  if [[ ${1:-} == --mode ]]; then
    (($# >= 3)) || return 2
    mode=$2
    shift 2
  fi
  (($# == 1)) || return 2

  local path=$1
  local existed=0
  [[ -d $path ]] && existed=1

  blm_require_command mkdir || return 1
  command mkdir -p -- "$path" || return $?
  ((existed == 0)) && _blm_change_mark

  if [[ -n $mode ]]; then
    blm_require_command stat || return 1
    blm_require_command chmod || return 1

    local current_mode requested_mode=$mode
    current_mode=$(command stat -c '%a' -- "$path") || return $?
    [[ $requested_mode == 0* ]] && requested_mode=${requested_mode#0}

    if [[ $current_mode != "$requested_mode" ]]; then
      command chmod "$mode" -- "$path" || return $?
      _blm_change_mark
    fi
  fi
}

blm_ensure_symlink() {
  _blm_change_begin
  (($# == 2)) || return 2

  local target=$1
  local link=$2

  if [[ -L $link ]]; then
    blm_require_command readlink || return 1
    [[ $(command readlink -- "$link") == "$target" ]] && return 0
    blm_error "Symlink exists with a different target: $link"
    return 1
  fi

  if [[ -e $link ]]; then
    blm_error "Path exists and is not a symlink: $link"
    return 1
  fi

  blm_require_command ln || return 1
  command ln -s -- "$target" "$link" || return $?
  _blm_change_mark
}

blm_ensure_mode() {
  _blm_change_begin
  (($# == 2)) || {
    blm_error "Usage: blm_ensure_mode <mode> <path>"
    return 2
  }

  local mode=$1
  local path=$2
  [[ -e $path || -L $path ]] || {
    blm_error "Path does not exist: $path"
    return 1
  }

  blm_require_command stat || return 1
  blm_require_command chmod || return 1

  local current_mode requested_mode=$mode
  current_mode=$(command stat -c '%a' -- "$path") || return $?
  [[ $requested_mode == 0* ]] && requested_mode=${requested_mode#0}

  [[ $current_mode == "$requested_mode" ]] && return 0

  command chmod "$mode" -- "$path" || return $?
  _blm_change_mark
}

blm_ensure_line() {
  _blm_change_begin
  (($# == 2)) || {
    blm_error "Usage: blm_ensure_line <path> <line>"
    return 2
  }

  local path=$1
  local wanted=$2
  local directory
  directory=$(blm_path_dirname "$path") || return $?

  [[ -d $directory ]] || {
    blm_error "Destination directory does not exist: $directory"
    return 1
  }

  if [[ -e $path && ! -f $path ]]; then
    blm_error "Path exists and is not a regular file: $path"
    return 1
  fi

  if [[ -f $path ]]; then
    local line
    while IFS= read -r line || [[ -n $line ]]; do
      [[ $line == "$wanted" ]] && return 0
    done <"$path"
  fi

  printf '%s\n' "$wanted" >>"$path" || return $?
  _blm_change_mark
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

  blm_require_command rm || return 1
  blm_require_command mv || return 1

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

  command mv -f -- "$tmp" "$path"
}
