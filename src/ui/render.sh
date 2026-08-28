#!/usr/bin/env bash

# Terminal rendering primitives.
#
# Human TTY output uses the theme/style registry and display-width helpers.
# Plain/JSON/non-TTY output remains deterministic. Existing call forms remain
# supported while --style enables per-call visual overrides.

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

_blm_ui_effective_charset() {
  _blm_ui_theme_validate || return $?
  case ${BLM_UI_THEME:-default} in
    ascii | ci) printf '%s\n' ascii ;;
    *) _blm_ui_charset ;;
  esac
}

_blm_ui_rich_enabled() {
  _blm_ui_style_validate || return $?
  _blm_ui_theme_validate || return $?
  [[ ${BLM_UI_STYLE:-rich} == rich ]] || return 1
  [[ $(_blm_output_mode) == human ]] || return 1
  blm_is_tty
}

_blm_repeat_glyph() {
  (($# == 2)) || return 2
  local glyph=$1 count=$2 out="" i
  _blm_is_nonnegative_integer "$count" || return 2
  for ((i = 0; i < count; i++)); do out+=$glyph; done
  printf '%s' "$out"
}

_blm_panel_border_chars() {
  (($# == 2)) || return 2
  local style=$1 charset=$2
  if [[ $charset == ascii || $style == ascii ]]; then
    printf '%s\n' '+|+-'
    return 0
  fi
  case $style in
    rounded) printf '%s\n' '╭│╯─' ;;
    square) printf '%s\n' '┌│└─' ;;
    double) printf '%s\n' '╔║╚═' ;;
    *) return 2 ;;
  esac
}

# Public API: blm_panel
# Purpose: Render a titled block with selectable borders on capable terminals.
# Usage: blm_panel [--style rounded|square|double|minimal|ascii] <title> [line...]
# Returns: 0 on success; 2 for missing title or invalid UI/style policy.
# Output: Human TTY mode sizes the border using terminal display width.
# Side effects: None.
blm_panel() {
  (($# >= 1)) || return 2
  local style_override=''
  if [[ $1 == --style ]]; then
    (($# >= 3)) || return 2
    style_override=$2
    shift 2
  fi
  local title=$1
  shift
  local mode style charset title_width content_width line line_width
  mode=$(_blm_output_mode) || return $?
  style=$(_blm_ui_resolve_style panel "$style_override") || return $?

  if [[ $mode == json ]]; then
    if (($# == 0)); then
      printf '{"type":"panel","title":"%s","message":"","style":"%s"}\n' \
        "$(_blm_json_escape "$title")" "$style"
    else
      for line in "$@"; do
        printf '{"type":"panel","title":"%s","message":"%s","style":"%s"}\n' \
          "$(_blm_json_escape "$title")" "$(_blm_json_escape "$line")" "$style"
      done
    fi
    return 0
  fi

  if [[ $mode == plain ]]; then
    printf 'panel: %s\n' "$title"
    for line in "$@"; do printf '  %s\n' "$line"; done
    return 0
  fi

  if [[ $style == minimal ]] || ! blm_is_tty; then
    printf '%s\n' "$title"
    for line in "$@"; do printf '  %s\n' "$line"; done
    return 0
  fi

  title_width=$(blm_display_width "$title") || return $?
  content_width=$title_width
  for line in "$@"; do
    line_width=$(blm_display_width "$line") || return $?
    ((line_width > content_width)) && content_width=$line_width
  done

  charset=$(_blm_ui_effective_charset) || return $?
  local chars top_left vertical bottom_left horizontal top_right bottom_right
  chars=$(_blm_panel_border_chars "$style" "$charset") || return $?
  if [[ $chars == '+|+-' ]]; then
    top_left='+'; vertical='|'; bottom_left='+'; horizontal='-'; top_right='+'; bottom_right='+'
  else
    top_left=${chars:0:1}; vertical=${chars:1:1}; bottom_left=${chars:2:1}; horizontal=${chars:3:1}
    case $style in
      rounded) top_right='╮'; bottom_right='╯' ;;
      square) top_right='┐'; bottom_right='┘' ;;
      double) top_right='╗'; bottom_right='╝' ;;
    esac
  fi

  printf '%s%s %s %s%s\n' "$top_left" "$horizontal" "$title" \
    "$(_blm_repeat_glyph "$horizontal" "$((content_width - title_width + 1))")" "$top_right"
  for line in "$@"; do
    printf '%s ' "$vertical"
    _blm_pad_right "$content_width" "$line"
    printf ' %s\n' "$vertical"
  done
  printf '%s%s%s\n' "$bottom_left" "$(_blm_repeat_glyph "$horizontal" "$((content_width + 2))")" "$bottom_right"
}

# Public API: blm_table
# Purpose: Render tab-delimited rows with width-aware aligned columns.
# Usage: blm_table [--style unicode|ascii|compact|minimal] <row> [row...]
# Returns: 0 on success; 2 when no rows are supplied or style is invalid.
# Output: Human TTY mode aligns display cells; plain mode expands tabs; JSON
#         preserves each raw row and reports the resolved style.
# Side effects: None.
blm_table() {
  (($# >= 1)) || return 2
  local style_override=''
  if [[ $1 == --style ]]; then
    (($# >= 3)) || return 2
    style_override=$2
    shift 2
  fi
  (($# >= 1)) || return 2

  local mode style
  mode=$(_blm_output_mode) || return $?
  style=$(_blm_ui_resolve_style table "$style_override") || return $?

  if [[ $mode == json ]]; then
    local json_row
    for json_row in "$@"; do
      printf '{"type":"table-row","value":"%s","style":"%s"}\n' \
        "$(_blm_json_escape "$json_row")" "$style"
    done
    return 0
  fi

  if [[ $mode == plain ]] || ! blm_is_tty; then
    local plain_row
    for plain_row in "$@"; do printf '%s\n' "${plain_row//$'\t'/  }"; done
    return 0
  fi

  local -a rows=("$@") widths=()
  local row cell col max_cols=0 cell_width
  local -a cells=()
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r -a cells <<<"$row"
    ((${#cells[@]} > max_cols)) && max_cols=${#cells[@]}
    for ((col = 0; col < ${#cells[@]}; col++)); do
      [[ -n ${widths[col]+x} ]] || widths[col]=0
      cell_width=$(blm_display_width "${cells[col]}") || return $?
      ((cell_width > widths[col])) && widths[col]=$cell_width
    done
  done

  local charset sep divider_sep divider_glyph header_divider=1
  charset=$(_blm_ui_effective_charset) || return $?
  case $style in
    unicode)
      if [[ $charset == unicode ]]; then sep=' │ '; divider_sep='─┼─'; divider_glyph='─'; else sep=' | '; divider_sep='-+-'; divider_glyph='-'; fi
      ;;
    ascii) sep=' | '; divider_sep='-+-'; divider_glyph='-' ;;
    compact) sep='  '; divider_sep='  '; divider_glyph='-'; header_divider=0 ;;
    minimal) sep='  '; divider_sep='  '; divider_glyph=' '; header_divider=0 ;;
  esac

  local row_index=0 rendered
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r -a cells <<<"$row"
    rendered=''
    for ((col = 0; col < max_cols; col++)); do
      cell=${cells[col]-}
      rendered+=$(_blm_pad_right "${widths[col]}" "$cell")
      ((col + 1 < max_cols)) && rendered+=$sep
    done
    printf '%s\n' "$rendered"
    if ((row_index == 0 && header_divider == 1)); then
      rendered=''
      for ((col = 0; col < max_cols; col++)); do
        rendered+=$(_blm_repeat_glyph "$divider_glyph" "${widths[col]}")
        ((col + 1 < max_cols)) && rendered+=$divider_sep
      done
      printf '%s\n' "$rendered"
    fi
    row_index=$((row_index + 1))
  done
}

# Public API: blm_tree
# Purpose: Render one depth-labelled tree entry; retained for line-oriented compatibility.
# Usage: blm_tree [--style unicode|ascii|minimal] <depth> <label>
# Returns: 0 on success; 2 for invalid depth/arguments/style policy.
# Output: JSON emits depth/label/style. Plain uses spaces only. Human TTY uses
#         a branch marker but cannot infer final-sibling topology from one row.
# Side effects: None.
blm_tree() {
  local style_override=''
  if (($# >= 1)) && [[ $1 == --style ]]; then
    (($# == 4)) || return 2
    style_override=$2
    shift 2
  fi
  (($# == 2)) || return 2
  _blm_is_nonnegative_integer "$1" || return 2
  local depth=$1 label=$2 mode indent='' style charset
  mode=$(_blm_output_mode) || return $?
  style=$(_blm_ui_resolve_style tree "$style_override") || return $?

  if [[ $mode == json ]]; then
    printf '{"type":"tree","depth":%s,"label":"%s","style":"%s"}\n' \
      "$depth" "$(_blm_json_escape "$label")" "$style"
    return 0
  fi

  printf -v indent '%*s' "$((depth * 2))" ''
  if [[ $mode == plain ]] || ! blm_is_tty || ((depth == 0)); then
    printf '%s%s\n' "$indent" "$label"
    return 0
  fi

  case $style in
    minimal) printf '%s- %s\n' "${indent:0:${#indent}-2}" "$label" ;;
    ascii) printf '%s+- %s\n' "${indent:0:${#indent}-2}" "$label" ;;
    unicode)
      charset=$(_blm_ui_effective_charset) || return $?
      if [[ $charset == unicode ]]; then
        printf '%s├─ %s\n' "${indent:0:${#indent}-2}" "$label"
      else
        printf '%s+- %s\n' "${indent:0:${#indent}-2}" "$label"
      fi
      ;;
  esac
}

_blm_tree_line_depth_label() {
  (($# == 1)) || return 2
  local raw=$1 depth=0
  while [[ ${raw:0:1} == $'\t' ]]; do
    depth=$((depth + 1))
    raw=${raw:1}
  done
  printf '%s\t%s\n' "$depth" "$raw"
}

# Public API: blm_tree_view
# Purpose: Render a complete tab-indented tree with correct sibling topology.
# Usage: blm_tree_view [--style unicode|ascii|minimal] <line> [line...]
#         Each line uses leading TAB characters to declare depth.
# Returns: 0 on success; 2 for invalid style or malformed depth jumps.
# Output: Rich mode infers branch continuation and last siblings (`├─`/`└─`);
#         ASCII uses `+-`/`\-`; plain/non-TTY uses two-space indentation.
# Side effects: None.
blm_tree_view() {
  (($# >= 1)) || return 2
  local style_override=''
  if [[ $1 == --style ]]; then
    (($# >= 3)) || return 2
    style_override=$2
    shift 2
  fi

  local style mode charset
  style=$(_blm_ui_resolve_style tree "$style_override") || return $?
  mode=$(_blm_output_mode) || return $?
  charset=$(_blm_ui_effective_charset) || return $?

  local -a raw_lines=("$@") depths=() labels=() lasts=()
  local parsed depth label i j next_depth previous_depth=-1 last
  for ((i = 0; i < ${#raw_lines[@]}; i++)); do
    parsed=$(_blm_tree_line_depth_label "${raw_lines[i]}") || return $?
    depth=${parsed%%$'\t'*}
    label=${parsed#*$'\t'}
    if ((i == 0 && depth != 0)); then return 2; fi
    if ((previous_depth >= 0 && depth > previous_depth + 1)); then return 2; fi
    depths[i]=$depth
    labels[i]=$label
    previous_depth=$depth
  done

  for ((i = 0; i < ${#raw_lines[@]}; i++)); do
    depth=${depths[i]}
    last=1
    for ((j = i + 1; j < ${#raw_lines[@]}; j++)); do
      next_depth=${depths[j]}
      ((next_depth < depth)) && break
      if ((next_depth == depth)); then last=0; break; fi
    done
    lasts[i]=$last
  done

  local -a ancestor_last=()
  local prefix level connector
  for ((i = 0; i < ${#raw_lines[@]}; i++)); do
    depth=${depths[i]}
    label=${labels[i]}
    last=${lasts[i]}

    if [[ $mode == json ]]; then
      printf '{"type":"tree-node","depth":%s,"last":%s,"label":"%s","style":"%s"}\n' \
        "$depth" "$([[ $last == 1 ]] && printf true || printf false)" "$(_blm_json_escape "$label")" "$style"
      ancestor_last[depth]=$last
      continue
    fi

    if [[ $mode == plain ]] || ! blm_is_tty; then
      printf -v prefix '%*s' "$((depth * 2))" ''
      printf '%s%s\n' "$prefix" "$label"
      ancestor_last[depth]=$last
      continue
    fi

    if ((depth == 0)); then
      printf '%s\n' "$label"
      ancestor_last[0]=$last
      continue
    fi

    prefix=''
    for ((level = 1; level < depth; level++)); do
      if [[ ${ancestor_last[level]:-1} == 1 ]]; then
        prefix+='  '
      elif [[ $style == unicode && $charset == unicode ]]; then
        prefix+='│ '
      elif [[ $style == minimal ]]; then
        prefix+='  '
      else
        prefix+='| '
      fi
    done

    case $style in
      minimal) connector='- ' ;;
      ascii) [[ $last == 1 ]] && connector='\\- ' || connector='+- ' ;;
      unicode)
        if [[ $charset == unicode ]]; then
          [[ $last == 1 ]] && connector='└─ ' || connector='├─ '
        else
          [[ $last == 1 ]] && connector='\\- ' || connector='+- '
        fi
        ;;
    esac
    printf '%s%s%s\n' "$prefix" "$connector" "$label"
    ancestor_last[depth]=$last
  done
}
