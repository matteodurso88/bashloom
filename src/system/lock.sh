#!/usr/bin/env bash

# Dependency-light directory locking based on atomic mkdir.
#
# Creating a directory is atomic on normal local Linux filesystems and gives a
# simple non-blocking lock primitive without requiring flock. Bashloom does not
# remove stale locks automatically because deciding staleness safely requires
# application-specific ownership/liveness policy.

# Public API: blm_lock_acquire
# Purpose: Acquire a non-blocking exclusive lock represented by a directory.
# Usage: blm_lock_acquire <lock-path>
# Returns:
#   0  Lock directory was created by this call.
#   1  mkdir unavailable, path already exists, or lock creation failed.
#   2  Invalid Bashloom arguments.
# Output: Conflict/failure diagnostic to stderr.
# Side effects: Creates the lock directory on success.
# External dependencies: mkdir, checked only at call time.
# Concurrency invariant: success belongs only to the process whose mkdir wins.
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

# Public API: blm_lock_release
# Purpose: Release a directory lock by removing its empty lock directory.
# Usage: blm_lock_release <lock-path>
# Returns: 0 on removal, 1 if absent/non-empty/dependency failure, 2 bad args.
# Output: Missing-lock diagnostic to stderr; rmdir diagnostics otherwise native.
# Side effects: Removes exactly the lock directory, never recursively.
# External dependencies: rmdir.
# Safety: rmdir rather than rm -rf prevents accidental deletion of lock contents
# and makes unexpected files inside a lock visible as a release failure.
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

# Public API: blm_with_lock
# Purpose: Acquire lock, execute one argv-safe command, then release the lock.
# Usage: blm_with_lock <lock-path> <command> [args...]
# Returns:
#   wrapped-command status when command fails;
#   release status when command succeeded but unlocking failed;
#   acquisition/usage status before command starts.
# Output: Wrapped command output plus any lock diagnostics.
# Side effects: Creates/removes lock directory and executes wrapped command.
# Failure precedence: command failure wins over release failure so the original
# operational error is never hidden by cleanup noise.
# Errexit invariant: wrapped command and release run inside conditional contexts.
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
