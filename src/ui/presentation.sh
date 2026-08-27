#!/usr/bin/env bash

# Presentation helpers that degrade cleanly across human/plain/JSON modes.
#
# Titles and sections are semantic records, not terminal decoration only. Human
# mode uses lightweight separators, while plain/JSON expose explicit record
# types so CI/log parsers do not have to reverse-engineer visual punctuation.

# Internal renderer: convert a semantic presentation type + message into the
# active output mode. Only known types are accepted in human mode so accidental
# internal misuse fails instead of silently inventing a new visual contract.
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

# Public API: blm_title
# Purpose: Emit a top-level presentation heading in the configured output mode.
# Usage: blm_title <message...>
# Returns: 0 on successful rendering; 2 for missing arguments/invalid mode/type.
# Output: One semantic title record to stdout.
# Side effects: None beyond output.
blm_title() {
  (($# >= 1)) || return 2
  _blm_emit_presentation title "$@"
}

# Public API: blm_section
# Purpose: Emit a subordinate section heading in the configured output mode.
# Usage: blm_section <message...>
# Returns: 0 on successful rendering; 2 for missing arguments/invalid mode/type.
# Output: One semantic section record to stdout.
# Side effects: None beyond output.
blm_section() {
  (($# >= 1)) || return 2
  _blm_emit_presentation section "$@"
}
