#!/usr/bin/env bash

# Advanced Linux-first filesystem primitives.

blm_checksum_sha256() {
  (($# == 1)) || return 2
  local path=$1
  [[ -f $path ]] || {
    blm_error "File does not exist: $path"
    return 1
  }
  blm_require_command sha256sum || return 1
  command sha256sum -- "$path" | {
    local checksum _
    read -r checksum _
    printf '%s\n' "$checksum"
  }
}

blm_backup() {
  (($# == 2)) || return 2
  local source=$1
  local backup=$2

  _blm_change_begin

  [[ -e $source || -L $source ]] || {
    blm_error "Backup source does not exist: $source"
    return 1
  }
  [[ ! -e $backup && ! -L $backup ]] || {
    blm_error "Backup destination already exists: $backup"
    return 1
  }

  blm_require_command cp || return 1
  command cp -a -- "$source" "$backup" || return $?
  _blm_change_mark
}

blm_safe_copy() {
  (($# == 2)) || return 2
  local source=$1
  local destination=$2

  _blm_change_begin

  [[ -e $source || -L $source ]] || {
    blm_error "Copy source does not exist: $source"
    return 1
  }
  [[ ! -e $destination && ! -L $destination ]] || {
    blm_error "Copy destination already exists: $destination"
    return 1
  }

  blm_require_command cp || return 1
  command cp -a -- "$source" "$destination" || return $?
  _blm_change_mark
}

blm_safe_move() {
  (($# == 2)) || return 2
  local source=$1
  local destination=$2

  _blm_change_begin

  [[ -e $source || -L $source ]] || {
    blm_error "Move source does not exist: $source"
    return 1
  }
  [[ ! -e $destination && ! -L $destination ]] || {
    blm_error "Move destination already exists: $destination"
    return 1
  }

  blm_require_command mv || return 1
  command mv -- "$source" "$destination" || return $?
  _blm_change_mark
}

blm_ensure_owner() {
  (($# == 2)) || return 2
  local owner_group=$1
  local path=$2

  _blm_change_begin

  [[ $owner_group == *:* ]] || {
    blm_error "Owner must use user:group form: $owner_group"
    return 2
  }
  [[ -e $path || -L $path ]] || {
    blm_error "Path does not exist: $path"
    return 1
  }

  blm_require_command stat || return 1
  local current
  current=$(command stat -c '%U:%G' -- "$path") || return $?
  [[ $current == "$owner_group" ]] && return 0

  blm_require_command chown || return 1
  command chown -- "$owner_group" "$path" || return $?
  _blm_change_mark
}
