#!/usr/bin/env bash

# Idempotent and atomic filesystem helpers.
#
# Mutating ensure-functions participate in Bashloom change tracking: each call
# resets BLM_LAST_CHANGED and marks it only after an actual successful mutation.
# Aggregate BLM_CHANGED remains sticky until the caller resets its run scope.
#
# Linux-first note: mode inspection and mode preservation rely on GNU `stat -c`
# and `chmod --reference` semantics. These feature-specific assumptions are
# checked only when the corresponding operations are invoked.

_blm_normalize_numeric_mode() {
  (($# == 1)) || return 2
  local mode=$1
  [[ $mode =~ ^0?[0-7]{3,4}$ ]] || {
    blm_error "Invalid numeric mode: $mode"
    return 2
  }
  while [[ $mode == 0* && ${#mode} -gt 1 ]]; do
    mode=${mode#0}
  done
  printf '%s\n' "$mode"
}

# Public API: blm_ensure_dir
# Purpose: Ensure a directory exists and optionally converge its numeric mode.
# Usage: blm_ensure_dir [--mode MODE] <path>
# Returns:
#   0  Directory exists after the call and requested mode (if any) is correct.
#   1  Required utility or filesystem operation failed.
#   2  Invalid Bashloom arguments/mode.
# Output: Native utility diagnostics plus Bashloom dependency errors as needed.
# Side effects: May create parent directories and/or chmod the final directory.
# Change tracking:
#   Marks changed when the directory is newly created or its mode is corrected;
#   an already-converged directory leaves BLM_LAST_CHANGED=0.
# External dependencies: mkdir; GNU stat/chmod only when --mode is supplied.
blm_ensure_dir() {
  _blm_change_begin

  local mode='' requested_mode=''
  if [[ ${1:-} == --mode ]]; then
    (($# >= 3)) || return 2
    mode=$2
    requested_mode=$(_blm_normalize_numeric_mode "$mode") || return $?
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

    local current_mode
    current_mode=$(command stat -c '%a' -- "$path") || return $?
    if [[ $current_mode != "$requested_mode" ]]; then
      command chmod "$mode" -- "$path" || return $?
      _blm_change_mark
    fi
  fi
}

# Public API: blm_ensure_symlink
# Purpose: Ensure a symlink exists with exactly the requested lexical target.
# Usage: blm_ensure_symlink <target> <link>
# Returns:
#   0  Correct symlink already existed or was created.
#   1  Conflicting path/target, missing dependency, or ln/readlink failure.
#   2  Invalid arguments.
# Output: Conflict/dependency errors to stderr; native command diagnostics remain.
# Side effects: Creates the symlink only when link path is absent.
# Change tracking: Creation marks changed; exact existing target is a no-op.
# Safety:
#   A symlink pointing elsewhere is never silently replaced, and a non-symlink
#   path is never removed. Target comparison is lexical, not canonicalized.
# External dependencies: ln for creation; readlink only for existing symlinks.
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

# Public API: blm_ensure_mode
# Purpose: Converge one existing path to an exact numeric permission mode.
# Usage: blm_ensure_mode <mode> <path>
# Returns:
#   0  Mode already matched or chmod succeeded.
#   1  Path missing, dependency unavailable, or stat/chmod failed.
#   2  Invalid arguments/mode.
# Output: Bashloom errors/native utility diagnostics to stderr.
# Side effects: May chmod the path; marks change only after successful chmod.
# External dependencies: GNU/Linux stat (`-c`) and chmod.
# Notes: Symlink behavior follows platform chmod semantics; callers needing link
# ownership rather than target ownership should use blm_ensure_owner.
blm_ensure_mode() {
  _blm_change_begin
  (($# == 2)) || {
    blm_error "Usage: blm_ensure_mode <mode> <path>"
    return 2
  }

  local mode=$1
  local path=$2
  local requested_mode
  requested_mode=$(_blm_normalize_numeric_mode "$mode") || return $?

  [[ -e $path || -L $path ]] || {
    blm_error "Path does not exist: $path"
    return 1
  }

  blm_require_command stat || return 1
  blm_require_command chmod || return 1

  local current_mode
  current_mode=$(command stat -c '%a' -- "$path") || return $?
  [[ $current_mode == "$requested_mode" ]] && return 0

  command chmod "$mode" -- "$path" || return $?
  _blm_change_mark
}

# Public API: blm_ensure_line
# Purpose: Ensure one exact literal single line appears at least once in a file.
# Usage: blm_ensure_line <path> <line>
# Returns:
#   0  Exact line already existed or was appended successfully.
#   1  Parent missing, destination non-regular, or append failed.
#   2  Invalid arguments or multiline/control-line data.
# Output: Bashloom validation errors to stderr.
# Side effects: Creates/appends the file when the line is absent; marks change.
# Matching semantics:
#   Equality is literal Bash string equality. No regex, trimming, escaping or
#   variable expansion is applied, so reruns converge on exactly caller data.
# Safety: Parent directories are never created implicitly. LF/CR are rejected
# because this API intentionally converges exactly one logical text line.
blm_ensure_line() {
  _blm_change_begin
  (($# == 2)) || {
    blm_error "Usage: blm_ensure_line <path> <line>"
    return 2
  }

  local path=$1
  local wanted=$2
  if [[ $wanted == *$'\n'* || $wanted == *$'\r'* ]]; then
    blm_error "blm_ensure_line requires single-line data"
    return 2
  fi

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

# Public API: blm_atomic_write
# Purpose: Replace/create one file from a producer command without exposing a
# partially written destination.
# Usage: blm_atomic_write <path> <producer-command> [args...]
# Returns:
#   0  Same-directory temporary file was renamed into place successfully.
#   producer status when producer fails;
#   1  Directory/dependency/mode-preservation operation failed;
#   2  Invalid arguments.
# Output:
#   Producer stdout is captured into the temporary file; producer stderr remains
#   visible. Bashloom/native filesystem errors remain on stderr.
# Side effects:
#   Creates a secure temporary file in the destination directory and atomically
#   renames it over the destination on success. Existing destination mode is
#   preserved with GNU `chmod --reference` before rename.
# Failure safety:
#   Producer/mode failures remove the temp and leave the original destination
#   untouched. Same-directory temp placement provides same-filesystem rename
#   semantics. This is atomic replacement, NOT fsync/power-loss durability.
# Security: Producer is invoked as original argv; no eval or shell text parsing.
# External dependencies: rm, mv, mktemp; GNU chmod when destination exists.
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
      blm_error "Unable to preserve destination mode; GNU chmod --reference is required"
      return "$status"
    }
  fi

  command mv -f -- "$tmp" "$path"
}
