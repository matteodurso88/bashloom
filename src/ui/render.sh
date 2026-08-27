#!/usr/bin/env bash

# Terminal rendering primitives.
#
# Human TTY output defaults to a richer Unicode presentation when the current
# locale advertises UTF-8. Plain/JSON output remains deterministic and ASCII
# safe. Set BLM_UI_CHARSET=ascii|unicode to override auto detection.

# Internal helper: resolve the character-set policy used by human TTY output.
# BLM_UI_CHARSET accepts auto (default), ascii or unicode. Auto relies only on
# locale variables and therefore introduces no external dependency.
_blm_ui_charset() {
  local requested=${BLM_UI_CHARSET:-auto}
  case $requested in
    ascii | unicode) printf '%s\n' "$requested" ;;
    auto)
      local locale_text="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
      case ${locale_text,,} in
        *utf-8* | *utf8*) printf '%s\n' unicode ;;
        *) printf '%s\n' ascii ;;
      esac
      ;;
    *)
      blm_error "Invalid BLM_UI_CHARSET: $requested"
      return 2
      ;;
  esac
}

# Internal helper: return success only when rich human rendering is appropriate.
# BLM_UI_STYLE=minimal disables rich borders while preserving human output.
_blm_ui_rich_enabled() {
  [[ ${BLM_UI_STYLE:-rich} == rich ]] || return 1
  [[ $(_blm_output_mode) == human ]] || return 1
  blm_is_tty
}

# Internal helper: repeat a single-byte or UTF-8 glyph N times without seq/tr.
_blm_repeat_glyph() {
  (($# == 2)) || return 2
  local glyph=$1 count=$2 out="" i
  _blm_is_nonnegative_integer "$count" || return 2
  for ((i = 0; i < count; i++)); do out+=$glyph; done
  printf '%s' "$out"
}

# Public API: blm_panel
# Purpose: Render a titled block of text with a rich border on capable terminals.
# Usage: blm_panel <title> [line...]
# Returns: 0 on success; 2 for missing title or invalid UI charset policy.
# Output: Rich human TTY mode sizes the border to the longest title/body line.
#         Minimal human uses ASCII. Plain uses labelled lines. JSON emits one
#         machine-readable panel record per supplied line.
# Side effects: None.
# Portability: Unicode borders are used only when charset policy resolves to
#              unicode; ASCII remains the deterministic fallback.
blm_panel() {
  (($# >= 1)) || return 2
  local title=$1
  shift
  local mode
  mode=$(_blm_output_mode) || return $?

  if [[ $mode == json ]]; then
    if (($# == 0)); then
      printf '{"type":"panel","title":"%s","message":""}\n' "$(_blm_json_escape "$title")"
    else
      local line
      for line in "$@"; do
        printf '{"type":"panel","title":"%s","message":"%s"}\n' \
          "$(_blm_json_escape "$title")" "$(_blm_json_escape "$line")"
      done
    fi
    return 0
  fi

  if [[ $mode == plain ]]; then
    printf 'panel: %s\n' "$title"
    local line
    for line in "$@"; do printf '  %s\n' "$line"; done
    return 0
  fi

  local width=${#title} line
  for line in "$@"; do ((${#line} > width)) && width=${#line}; done
  width=$((width + 2))

  local charset
  charset=$(_blm_ui_charset) || return $?
  if _blm_ui_rich_enabled && [[ $charset == unicode ]]; then
    printf '╭─ %s %s╮\n' "$title" "$(_blm_repeat_glyph '─' "$((width - ${#title} - 1))")"
    for line in "$@"; do printf '│ %-*s │\n' "$width" "$line"; done
    printf '╰%s╯\n' "$(_blm_repeat_glyph '─' "$((width + 2))")"
  else
    printf '+-- %s --+\n' "$title"
    for line in "$@"; do printf '| %s\n' "$line"; done
    printf '+%s+\n' "$(_blm_repeat_glyph '-' "$((width + 2))")"
  fi
}

# Public API: blm_table
# Purpose: Render tab-delimited rows with aligned columns in human mode.
# Usage: blm_table <row> [row...]
# Returns: 0 on success; 2 when no rows are supplied.
# Output: Human mode computes column widths in pure Bash and aligns cells;
#         plain mode expands tabs to two spaces; JSON preserves each raw row.
# Side effects: None.
# Notes: The first row is treated as a header for human rendering only.
blm_table() {
  (($# >= 1)) || return 2
  local mode
  mode=$(_blm_output_mode) || return $?

  if [[ $mode == json ]]; then
    local row
    for row in "$@"; do
      printf '{"type":"table-row","value":"%s"}\n' "$(_blm_json_escape "$row")"
    done
    return 0
  fi

  if [[ $mode == plain ]] || ! blm_is_tty; then
    local row
    for row in "$@"; do printf '%s\n' "${row//$'\t'/  }"; done
    return 0
  fi

  local -a rows=("$@") widths=()
  local row cell col max_cols=0
  local -a cells=()
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r -a cells <<<"$row"
    ((${#cells[@]} > max_cols)) && max_cols=${#cells[@]}
    for ((col = 0; col < ${#cells[@]}; col++)); do
      [[ -n ${widths[$col]+x} ]] || widths[$col]=0
      ((${#cells[$col]} > widths[$col])) && widths[$col]=${#cells[$col]}
    done
  done

  local charset sep='  '
  charset=$(_blm_ui_charset) || return $?
  [[ $charset == unicode ]] && sep=' │ '

  local row_index=0 rendered="" i
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r -a cells <<<"$row"
    rendered=""
    for ((col = 0; col < max_cols; col++)); do
      cell=${cells[$col]-}
      printf -v rendered '%s%-*s' "$rendered" "${widths[$col]}" "$cell"
      ((col + 1 < max_cols)) && rendered+=$sep
    done
    printf '%s\n' "$rendered"
    if ((row_index == 0)); then
      rendered=""
      for ((col = 0; col < max_cols; col++)); do
        rendered+=$(_blm_repeat_glyph '-' "${widths[$col]}")
        ((col + 1 < max_cols)) && rendered+='---'
      done
      printf '%s\n' "$rendered"
    fi
    row_index=$((row_index + 1))
  done
}

# Public API: blm_tree
# Purpose: Render one depth-labelled tree entry with rich branch glyphs where supported.
# Usage: blm_tree <depth> <label>
# Returns: 0 on success; 2 for invalid depth/arguments/UI charset policy.
# Output: JSON emits explicit depth/label. Plain uses spaces only. Human TTY
#         uses Unicode branch glyphs when available, otherwise ASCII markers.
# Side effects: None.
# Notes: This line-oriented primitive cannot infer whether an item is the final
#        sibling; callers needing exact last-child topology should render their
#        own connector semantics on top of the depth information.
blm_tree() {
  (($# == 2)) || return 2
  _blm_is_nonnegative_integer "$1" || return 2
  local depth=$1 label=$2 mode indent=""
  mode=$(_blm_output_mode) || return $?

  if [[ $mode == json ]]; then
    printf '{"type":"tree","depth":%s,"label":"%s"}\n' "$depth" "$(_blm_json_escape "$label")"
    return 0
  fi

  printf -v indent '%*s' "$((depth * 2))" ''
  if [[ $mode == plain ]] || ! blm_is_tty || ((depth == 0)); then
    printf '%s%s\n' "$indent" "$label"
    return 0
  fi

  local charset
  charset=$(_blm_ui_charset) || return $?
  if [[ $charset == unicode ]]; then
    printf '%s├─ %s\n' "${indent:0:${#indent}-2}" "$label"
  else
    printf '%s+- %s\n' "${indent:0:${#indent}-2}" "$label"
  fi
}
