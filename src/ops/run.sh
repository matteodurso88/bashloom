#!/usr/bin/env bash

# Command execution primitives.
#
# This module never enables shell options and never evaluates command strings.
# Commands are always executed from the original argument vector, preserving
# spaces, wildcard characters and other data exactly as supplied by the caller.

# Internal helper: render argv for human dry-run diagnostics with Bash `%q`.
# This output is descriptive shell syntax only; it is never fed back into eval
# or another shell for execution.
_blm_format_command() {
  local arg
  local rendered=""

  for arg in "$@"; do
    printf -v arg '%q' "$arg"
    if [[ -n $rendered ]]; then
      rendered+=" "
    fi
    rendered+="$arg"
  done

  printf '%s\n' "$rendered"
}

# Public API: blm_run
# Purpose: Execute one argv-safe command with optional local/global dry-run.
# Usage: blm_run [--dry-run] [--] <command> [args...]
# Environment:
#   BLM_DRY_RUN=1|true enables dry-run unless caller simply executes normally;
#   explicit --dry-run always enables it for this invocation.
# Returns:
#   exact wrapped-command status when executed;
#   0 for a dry-run record;
#   2 for missing command/unknown Bashloom option.
# Output:
#   dry-run emits one informational record; normal execution preserves the
#   wrapped command's native stdout/stderr.
# Side effects: Exactly those of the wrapped command; dry-run performs none.
# Errexit invariant:
#   The command runs in the condition of `if`, so a caller's `set -e` cannot
#   terminate the shell before Bashloom captures and returns the real status.
# Security: No eval/string command reconstruction is used.
blm_run() {
  local dry_run=${BLM_DRY_RUN:-0}

  while (($# > 0)); do
    case $1 in
      --dry-run)
        dry_run=1
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        blm_error "Unknown blm_run option: $1"
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  if (($# == 0)); then
    blm_error "blm_run requires a command"
    return 2
  fi

  if [[ $dry_run == 1 || $dry_run == true ]]; then
    blm_info "DRY-RUN: $(_blm_format_command "$@")"
    return 0
  fi

  local status
  # Keep execution inside an if-condition to make status capture safe even when
  # the consumer sourced Bashloom under errexit (`set -e`).
  if "$@"; then
    status=0
  else
    status=$?
  fi

  return "$status"
}
