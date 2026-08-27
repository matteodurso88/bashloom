#!/usr/bin/env bash

# Return an error for a missing runtime requirement.
_blm_require_fail() {
  printf '[ERROR] %s\n' "$*" >&2
  return 1
}

blm_require_command() {
  local command_name="$1"
  blm_has_command "$command_name" || _blm_require_fail "Required command not found: $command_name"
}

blm_require_file() {
  local path="$1"
  [[ -f "$path" ]] || _blm_require_fail "Required file not found: $path"
}

blm_require_dir() {
  local path="$1"
  [[ -d "$path" ]] || _blm_require_fail "Required directory not found: $path"
}

blm_require_env() {
  local name="$1"
  [[ -n "${!name:-}" ]] || _blm_require_fail "Required environment variable is empty or unset: $name"
}

blm_require_root() {
  ((EUID == 0)) || _blm_require_fail "Root privileges are required"
}

blm_require_readable() {
  local path="$1"
  [[ -r "$path" ]] || _blm_require_fail "Path is not readable: $path"
}

blm_require_writable() {
  local path="$1"
  [[ -w "$path" ]] || _blm_require_fail "Path is not writable: $path"
}

blm_require_executable() {
  local path="$1"
  [[ -x "$path" ]] || _blm_require_fail "Path is not executable: $path"
}
