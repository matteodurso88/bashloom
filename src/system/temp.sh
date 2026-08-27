#!/usr/bin/env bash

# Secure temporary resource helpers.
#
# mktemp is required only when these helpers are invoked; sourcing Bashloom
# remains dependency-free. A subshell applies umask 077 without modifying the
# caller's process umask, preserving source safety.

# Public API: blm_temp_file
# Purpose: Create one securely named temporary file and print its path.
# Usage: blm_temp_file [directory]
# Directory default: ${TMPDIR:-/tmp}.
# Returns:
#   0  mktemp created the file.
#   1  mktemp missing, directory absent, or creation failed.
# Output: Created path to stdout; Bashloom errors to stderr.
# Side effects: Creates one file, normally mode 0600 under umask 077.
# External dependencies: mktemp, checked only at call time.
# Source-safety: umask change is confined to a subshell.
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

# Public API: blm_temp_dir
# Purpose: Create one securely named temporary directory and print its path.
# Usage: blm_temp_dir [directory]
# Directory default: ${TMPDIR:-/tmp}.
# Returns:
#   0  mktemp created the directory.
#   1  mktemp missing, parent absent, or creation failed.
# Output: Created path to stdout; Bashloom errors to stderr.
# Side effects: Creates one directory, normally mode 0700 under umask 077.
# External dependencies: mktemp, checked only at call time.
# Source-safety: caller umask is never modified.
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
