#!/usr/bin/env bash

# Deterministic lightweight terminal rendering primitives.
#
# Rendering intentionally remains line-oriented so output degrades cleanly in
# logs, pipes and CI. No cursor addressing or full-screen TUI state is used.

# Public API: blm_panel
# Purpose: Render a titled block of text.
# Usage: blm_panel <title> [line...]
# Returns: 0 on success; 2 for missing title.
# Output: Human mode uses an ASCII border; plain mode uses labelled lines; JSON
#         emits one panel record per supplied line.
# Side effects: None.
blm_panel() {
  (($# >= 1)) || return 2
  local title=$1
  shift
  local mode
  mode=$(_blm_output_mode) || return $?

  case $mode in
    human)
      printf '+-- %s --+\n' "$title"
      local line
      for line in "$@"; do printf '| %s\n' "$line"; done
      printf '+%*s+\n' "$(( ${#title} + 6 ))" '' | tr ' ' '-'
      ;;
    plain)
      printf 'panel: %s\n' "$title"
      local line
      for line in "$@"; do printf '  %s\n' "$line"; done
      ;;
    json)
      if (($# == 0)); then
        printf '{"type":"panel","title":"%s","message":""}\n' "$(_blm_json_escape "$title")"
      else
        local line
        for line in "$@"; do
          printf '{"type":"panel","title":"%s","message":"%s"}\n' \
            "$(_blm_json_escape "$title")" "$(_blm_json_escape "$line")"
        done
      fi
      ;;
  esac
}

# Public API: blm_table
# Purpose: Render rows supplied as tab-delimited strings without column parsing dependencies.
# Usage: blm_table <row> [row...]
# Returns: 0 on success; 2 when no rows are supplied.
# Output: Human/plain modes expand tabs to two spaces; JSON emits one row record
#         preserving the original tab-delimited payload.
# Side effects: None.
blm_table() {
  (($# >= 1)) || return 2
  local mode
  mode=$(_blm_output_mode) || return $?
  local row
  for row in "$@"; do
    if [[ $mode == json ]]; then
      printf '{"type":"table-row","value":"%s"}\n' "$(_blm_json_escape "$row")"
    else
      printf '%s\n' "${row//$'\t'/  }"
    fi
  done
}

# Public API: blm_tree
# Purpose: Render a simple depth-labelled tree entry.
# Usage: blm_tree <depth> <label>
# Returns: 0 on success; 2 for invalid depth/arguments.
# Output: Human/plain modes indent with two spaces per depth; JSON emits depth
#         and label fields.
# Side effects: None.
blm_tree() {
  (($# == 2)) || return 2
  _blm_is_nonnegative_integer "$1" || return 2
  local depth=$1 label=$2 mode indent=""
  mode=$(_blm_output_mode) || return $?
  printf -v indent '%*s' "$((depth * 2))" ''
  if [[ $mode == json ]]; then
    printf '{"type":"tree","depth":%s,"label":"%s"}\n' "$depth" "$(_blm_json_escape "$label")"
  else
    printf '%s%s\n' "$indent" "$label"
  fi
}
