#!/usr/bin/env bash

# Command execution primitives.
#
# This module never enables shell options and never evaluates command strings.
# Commands are always executed from the original argument vector.

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
  if "$@"; then
    status=0
  else
    status=$?
  fi

  return "$status"
}
