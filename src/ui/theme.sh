#!/usr/bin/env bash

# Terminal theme and style registry.
#
# The registry resolves stable component styles without mutating caller state.
# Global theme selection is controlled through BLM_UI_THEME. BLM_UI_STYLE keeps
# the existing rich|minimal density contract and is validated centrally.

_blm_ui_style_validate() {
  local style=${BLM_UI_STYLE:-rich}
  case $style in
    rich | minimal) return 0 ;;
    *)
      blm_error "Invalid BLM_UI_STYLE: $style"
      return 2
      ;;
  esac
}

_blm_ui_theme_validate() {
  local theme=${BLM_UI_THEME:-default}
  case $theme in
    default | modern | minimal | ascii | ci) return 0 ;;
    *)
      blm_error "Invalid BLM_UI_THEME: $theme"
      return 2
      ;;
  esac
}

_blm_ui_component_style_allowed() {
  (($# == 2)) || return 2
  local component=$1 style=$2
  case $component in
    spinner)
      case $style in braille | line | dots | pulse) return 0 ;; esac
      ;;
    progress)
      case $style in blocks | bar | thin | dots | percent) return 0 ;; esac
      ;;
    panel)
      case $style in rounded | square | double | minimal | ascii) return 0 ;; esac
      ;;
    table)
      case $style in unicode | ascii | compact | minimal) return 0 ;; esac
      ;;
    tree)
      case $style in unicode | ascii | minimal) return 0 ;; esac
      ;;
    *) return 2 ;;
  esac
  return 1
}

_blm_ui_theme_default_style() {
  (($# == 2)) || return 2
  local theme=$1 component=$2
  case "$theme:$component" in
    default:spinner) printf '%s\n' braille ;;
    default:progress) printf '%s\n' blocks ;;
    default:panel) printf '%s\n' rounded ;;
    default:table) printf '%s\n' unicode ;;
    default:tree) printf '%s\n' unicode ;;

    modern:spinner) printf '%s\n' dots ;;
    modern:progress) printf '%s\n' thin ;;
    modern:panel) printf '%s\n' rounded ;;
    modern:table) printf '%s\n' compact ;;
    modern:tree) printf '%s\n' unicode ;;

    minimal:spinner) printf '%s\n' line ;;
    minimal:progress) printf '%s\n' percent ;;
    minimal:panel) printf '%s\n' minimal ;;
    minimal:table) printf '%s\n' minimal ;;
    minimal:tree) printf '%s\n' minimal ;;

    ascii:spinner) printf '%s\n' line ;;
    ascii:progress) printf '%s\n' bar ;;
    ascii:panel) printf '%s\n' ascii ;;
    ascii:table) printf '%s\n' ascii ;;
    ascii:tree) printf '%s\n' ascii ;;

    ci:spinner) printf '%s\n' line ;;
    ci:progress) printf '%s\n' percent ;;
    ci:panel) printf '%s\n' minimal ;;
    ci:table) printf '%s\n' minimal ;;
    ci:tree) printf '%s\n' minimal ;;
    *) return 2 ;;
  esac
}

_blm_ui_component_env_name() {
  (($# == 1)) || return 2
  case $1 in
    spinner) printf '%s\n' BLM_SPINNER_STYLE ;;
    progress) printf '%s\n' BLM_PROGRESS_STYLE ;;
    panel) printf '%s\n' BLM_PANEL_STYLE ;;
    table) printf '%s\n' BLM_TABLE_STYLE ;;
    tree) printf '%s\n' BLM_TREE_STYLE ;;
    *) return 2 ;;
  esac
}

_blm_ui_resolve_style() {
  (($# >= 1 && $# <= 2)) || return 2
  local component=$1 local_override=${2:-} theme env_name env_value resolved
  _blm_ui_style_validate || return $?
  _blm_ui_theme_validate || return $?

  if [[ ${BLM_UI_STYLE:-rich} == minimal ]]; then
    case $component in
      spinner) printf '%s\n' line ;;
      progress) printf '%s\n' percent ;;
      panel | table | tree) printf '%s\n' minimal ;;
      *) return 2 ;;
    esac
    return 0
  fi

  if [[ -n $local_override ]]; then
    _blm_ui_component_style_allowed "$component" "$local_override" || {
      blm_error "Invalid $component style: $local_override"
      return 2
    }
    printf '%s\n' "$local_override"
    return 0
  fi

  env_name=$(_blm_ui_component_env_name "$component") || return $?
  env_value=${!env_name:-}
  if [[ -n $env_value ]]; then
    _blm_ui_component_style_allowed "$component" "$env_value" || {
      blm_error "Invalid $env_name: $env_value"
      return 2
    }
    printf '%s\n' "$env_value"
    return 0
  fi

  theme=${BLM_UI_THEME:-default}
  resolved=$(_blm_ui_theme_default_style "$theme" "$component") || return $?
  _blm_ui_component_style_allowed "$component" "$resolved" || return 2
  printf '%s\n' "$resolved"
}

# Public API: blm_ui_theme
# Purpose: Report the active validated terminal theme preset.
# Usage: blm_ui_theme
# Returns: 0 on success; 2 for invalid BLM_UI_THEME/BLM_UI_STYLE policy.
# Output: One theme name on stdout.
# Side effects: None.
blm_ui_theme() {
  (($# == 0)) || return 2
  _blm_ui_style_validate || return $?
  _blm_ui_theme_validate || return $?
  printf '%s\n' "${BLM_UI_THEME:-default}"
}

# Public API: blm_ui_style
# Purpose: Resolve the active style for one terminal UI component.
# Usage: blm_ui_style <spinner|progress|panel|table|tree>
# Returns: 0 on success; 2 for unknown component or invalid style configuration.
# Output: One resolved component style on stdout.
# Side effects: None.
blm_ui_style() {
  (($# == 1)) || return 2
  _blm_ui_resolve_style "$1"
}
