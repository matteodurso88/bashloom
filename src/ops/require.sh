#!/usr/bin/env bash

# Return an error for a missing runtime requirement.
_blm_require_fail() {
  printf '[ERROR] %s\n' "$*" >&2
  return 1
}

# Require an executable command to exist in PATH.
blm_require_command() {
  local command_name="$1"
  blm_has_command "$command_name" || _blm_require_fail "Required command not found: $command_name"
}

# Require a regular file to exist.
blm_require_file() {
  local path="$1"
  [[ -f "$path" ]] || _blm_require_fail "Required file not found: $path"
}

# Require a directory to exist.
blm_require_dir() {
  local path="$1"
  [[ -d "$path" ]] || _blm_require_fail "Required directory not found: $path"
}

# Require an environment variable to be set and non-empty.
blm_require_env() {
  local name="$1"
  [[ -n "${!name:-}" ]] || _blm_require_fail "Required environment variable is empty or unset: $name"
}
