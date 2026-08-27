#!/usr/bin/env bash

# Presentation helpers that degrade cleanly across human/plain/JSON modes.

_blm_emit_presentation() {
  (($# >= 2)) || return 2
  local type=$1
  shift
  local message=$*
  local mode
  mode=$(_blm_output_mode) || return $?

  case $mode in
    human)
      case $type in
        title) printf '\n=== %s ===\n' "$message" ;;
        section) printf '\n-- %s --\n' "$message" ;;
        *) return 2 ;;
      esac
      ;;
    plain)
      printf '%s: %s\n' "$type" "$message"
      ;;
    json)
      printf '{"type":"%s","message":"%s"}\n' \
        "$(_blm_json_escape "$type")" \
        "$(_blm_json_escape "$message")"
      ;;
  esac
}

blm_title() {
  (($# >= 1)) || return 2
  _blm_emit_presentation title "$@"
}

blm_section() {
  (($# >= 1)) || return 2
  _blm_emit_presentation section "$@"
}
