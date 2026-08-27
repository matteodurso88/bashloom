#!/usr/bin/env bash

# Advanced Linux-first filesystem primitives.
#
# These helpers prefer explicit refusal over silent replacement. Copy/move/backup
# destinations must not already exist, ownership changes never escalate
# privileges implicitly, and every mutating helper participates in Bashloom's
# aggregate/per-operation change tracking.

# Public API: blm_checksum_sha256
# Purpose: Print the SHA-256 digest of one regular file without filename suffix.
# Usage: blm_checksum_sha256 <file>
# Returns: 0 on successful digest, 1 for missing file/dependency/failure, 2 args.
# Output: Exactly the hexadecimal digest plus newline; errors to stderr.
# Side effects: Reads file only.
# External dependencies: sha256sum, making this helper Linux/GNU-oriented today.
blm_checksum_sha256() {
  (($# == 1)) || return 2
  local path=$1
  [[ -f $path ]] || {
    blm_error "File does not exist: $path"
    return 1
  }
  blm_require_command sha256sum || return 1

  local output
  output=$(command sha256sum -- "$path") || return $?
  # sha256sum emits `<digest>  <filename>`; only the digest is part of the public
  # Bashloom contract so paths/spaces never leak into machine use.
  printf '%s\n' "${output%% *}"
}

# Public API: blm_backup
# Purpose: Archive-copy one existing path to a new, non-existing backup path.
# Usage: blm_backup <source> <backup>
# Returns: 0 on copy, 1 for missing source/existing destination/cp failure, 2 args.
# Output: Bashloom errors plus native cp diagnostics.
# Side effects: Creates destination using `cp -a`; marks change only on success.
# Safety: Existing backup paths are never overwritten, including symlinks.
# External dependencies: cp.
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

# Public API: blm_safe_copy
# Purpose: Copy a file/tree/symlink only when destination does not already exist.
# Usage: blm_safe_copy <source> <destination>
# Returns: 0 on copy, 1 on precondition/cp failure, 2 invalid arguments.
# Output: Errors to stderr; native cp output behavior otherwise preserved.
# Side effects: Creates destination with archive semantics and marks change.
# Safety: No implicit overwrite; callers wanting replacement must opt into a
# separate atomic/backup workflow rather than depending on cp defaults.
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

# Public API: blm_safe_move
# Purpose: Move one path only to an absent destination.
# Usage: blm_safe_move <source> <destination>
# Returns: 0 on move, 1 on precondition/mv failure, 2 invalid arguments.
# Output: Errors to stderr; native mv diagnostics otherwise preserved.
# Side effects: Relocates/renames source and marks change after success.
# Safety: Explicit existence checks prevent mv overwrite semantics.
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

# Public API: blm_ensure_owner
# Purpose: Converge one path's owner/group to an explicit `user:group` pair.
# Usage: blm_ensure_owner <user:group> <path>
# Returns:
#   0  Already correct or chown succeeded.
#   1  Missing path/dependency or stat/chown failure.
#   2  Invalid arguments/owner form.
# Output: Bashloom errors plus native command diagnostics.
# Side effects: May change ownership and set BLM_LAST_CHANGED/BLM_CHANGED.
# External dependencies: GNU/Linux stat (`-c`) and chown.
# Security: Never invokes sudo; caller must already possess required privilege.
# Symlink policy: `chown -h` changes the link object rather than its target.
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
  command chown -h -- "$owner_group" "$path" || return $?
  _blm_change_mark
}
