#!/usr/bin/env bash

# Runtime precondition helpers.
#
# Requirement functions are predicates with diagnostics: they never install a
# missing dependency, create a path, escalate privileges or terminate the caller.
# This keeps policy at the application layer while giving scripts consistent
# early-failure checks.

# Internal helper: bootstrap a requirement failure with stable status 1.
# Direct stderr output is intentionally retained for this low-level precondition
# path so a missing requirement can still be reported if richer UI helpers are
# not available because source files were consumed unusually.
_blm_require_fail() {
  printf '[ERROR] %s\n' "$*" >&2
  return 1
}

# Public API: blm_require_command
# Purpose: Require a command name to resolve in the current PATH.
# Usage: blm_require_command <name>
# Returns: 0 when available, 1 when missing, 2 for invalid arguments.
# Output: Missing-command diagnostic to stderr.
# Side effects: None; never installs packages.
blm_require_command() {
  (($# == 1)) || return 2
  local command_name=$1
  blm_has_command "$command_name" || _blm_require_fail "Required command not found: $command_name"
}

# Public API: blm_require_file
# Purpose: Require an existing regular file.
# Usage: blm_require_file <path>
# Returns: 0 for a regular file, 1 otherwise, 2 for invalid arguments.
# Output: Failure diagnostic to stderr.
# Side effects: None.
blm_require_file() {
  (($# == 1)) || return 2
  local path=$1
  [[ -f $path ]] || _blm_require_fail "Required file not found: $path"
}

# Public API: blm_require_dir
# Purpose: Require an existing directory.
# Usage: blm_require_dir <path>
# Returns: 0 for a directory, 1 otherwise, 2 for invalid arguments.
# Output: Failure diagnostic to stderr.
# Side effects: None.
blm_require_dir() {
  (($# == 1)) || return 2
  local path=$1
  [[ -d $path ]] || _blm_require_fail "Required directory not found: $path"
}

# Public API: blm_require_env
# Purpose: Require a non-empty environment variable by validated shell name.
# Usage: blm_require_env <NAME>
# Returns: 0 when set/non-empty, 1 when unset/empty, 2 for invalid name/args.
# Output: Failure diagnostic to stderr.
# Side effects: None.
# Security: Variable-name validation precedes indirect expansion.
blm_require_env() {
  (($# == 1)) || return 2
  local name=$1
  _blm_valid_env_name "$name" || {
    _blm_require_fail "Invalid environment variable name: $name"
    return 2
  }
  [[ -n ${!name:-} ]] || _blm_require_fail "Required environment variable is empty or unset: $name"
}

# Public API: blm_require_root
# Purpose: Require that the current Bash process already runs with EUID 0.
# Usage: blm_require_root
# Returns: 0 as root, 1 otherwise, 2 if arguments are supplied.
# Output: Failure diagnostic to stderr.
# Side effects: None.
# Security: Never invokes sudo/su or performs implicit privilege escalation.
blm_require_root() {
  (($# == 0)) || return 2
  ((EUID == 0)) || _blm_require_fail "Root privileges are required"
}

# Public API: blm_require_readable
# Purpose: Require current-process read permission for a path.
# Usage: blm_require_readable <path>
# Returns: 0 when Bash `-r` succeeds, 1 otherwise, 2 for invalid arguments.
# Side effects: None.
blm_require_readable() {
  (($# == 1)) || return 2
  local path=$1
  [[ -r $path ]] || _blm_require_fail "Path is not readable: $path"
}

# Public API: blm_require_writable
# Purpose: Require current-process write permission for a path.
# Usage: blm_require_writable <path>
# Returns: 0 when Bash `-w` succeeds, 1 otherwise, 2 for invalid arguments.
# Side effects: None.
blm_require_writable() {
  (($# == 1)) || return 2
  local path=$1
  [[ -w $path ]] || _blm_require_fail "Path is not writable: $path"
}

# Public API: blm_require_executable
# Purpose: Require current-process execute/search permission for a path.
# Usage: blm_require_executable <path>
# Returns: 0 when Bash `-x` succeeds, 1 otherwise, 2 for invalid arguments.
# Side effects: None.
blm_require_executable() {
  (($# == 1)) || return 2
  local path=$1
  [[ -x $path ]] || _blm_require_fail "Path is not executable: $path"
}
