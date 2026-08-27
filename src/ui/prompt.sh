#!/usr/bin/env bash

# Interactive prompt primitives for terminal consumers.
#
# These helpers never fabricate answers in non-interactive environments. The
# caller must provide defaults explicitly when unattended execution is allowed.

# Public API: blm_prompt
# Purpose: Read one line from stdin, optionally falling back to a supplied default.
# Usage: blm_prompt <message> [default]
# Returns: 0 on successful input/default selection; 1 when input is unavailable
#          and no default exists; 2 for invalid arguments.
# Output: Writes the selected value to stdout. Prompt text is written to stderr.
# Side effects: Reads stdin when it is attached to a terminal.
blm_prompt() {
  (($# >= 1 && $# <= 2)) || return 2
  local message=$1 default=${2-} answer=""
  if [[ -t 0 ]]; then
    if (($# == 2)); then printf '%s [%s]: ' "$message" "$default" >&2; else printf '%s: ' "$message" >&2; fi
    IFS= read -r answer || return 1
    [[ -n $answer ]] || answer=$default
  elif (($# == 2)); then
    answer=$default
  else
    blm_error "Interactive input is unavailable: $message"
    return 1
  fi
  printf '%s\n' "$answer"
}

# Public API: blm_confirm
# Purpose: Ask a yes/no question with an optional explicit default.
# Usage: blm_confirm <message> [yes|no]
# Returns: 0 for yes; 1 for no/unavailable input; 2 for invalid default/arguments.
# Output: Prompt text goes to stderr; no stdout payload is emitted.
# Side effects: Reads stdin when interactive.
blm_confirm() {
  (($# >= 1 && $# <= 2)) || return 2
  local message=$1 default=${2-}
  case $default in "" | yes | no) ;; *) return 2 ;; esac
  local prompt_default="" answer
  [[ $default == yes ]] && prompt_default=Y
  [[ $default == no ]] && prompt_default=N
  if [[ -t 0 ]]; then
    if [[ -n $prompt_default ]]; then printf '%s [y/n] (%s): ' "$message" "$prompt_default" >&2; else printf '%s [y/n]: ' "$message" >&2; fi
    IFS= read -r answer || return 1
  elif [[ -n $default ]]; then
    answer=$default
  else
    blm_error "Interactive confirmation is unavailable: $message"
    return 1
  fi
  [[ -n $answer ]] || answer=$default
  case ${answer,,} in y | yes) return 0 ;; n | no) return 1 ;; *) return 2 ;; esac
}

# Public API: blm_password
# Purpose: Read a secret without terminal echo.
# Usage: blm_password <message>
# Returns: 0 on successful input; 1 when stdin is non-interactive/read fails;
#          2 for invalid arguments.
# Output: Secret value is written to stdout; prompt goes to stderr.
# Security: The function does not persist the secret and disables terminal echo
#           only for the duration of Bash read -s.
blm_password() {
  (($# == 1)) || return 2
  [[ -t 0 ]] || {
    blm_error "Interactive secret input is unavailable: $1"
    return 1
  }
  local answer
  printf '%s: ' "$1" >&2
  IFS= read -r -s answer || return 1
  printf '\n' >&2
  printf '%s\n' "$answer"
}

# Public API: blm_select
# Purpose: Select one value from a finite list, optionally using an explicit
#          default index for unattended execution.
# Usage: blm_select <message> [--default N] -- <option> [option...]
# Returns: 0 with the selected value; 1 when input is unavailable without a
#          default; 2 for invalid syntax/index/input.
# Output: Menu/prompt goes to stderr; selected option goes to stdout.
# Side effects: Reads stdin only when interactive.
blm_select() {
  (($# >= 3)) || return 2
  local message=$1 default=""
  shift
  if [[ ${1:-} == --default ]]; then
    (($# >= 3)) || return 2
    default=$2
    shift 2
  fi
  [[ ${1:-} == -- ]] || return 2
  shift
  (($# >= 1)) || return 2
  local -a options=("$@")
  [[ -z $default ]] || _blm_is_positive_integer "$default" || return 2
  [[ -z $default || $default -le ${#options[@]} ]] || return 2

  local choice="" i
  if [[ -t 0 ]]; then
    printf '%s\n' "$message" >&2
    for ((i = 0; i < ${#options[@]}; i++)); do printf '  %d) %s\n' "$((i + 1))" "${options[$i]}" >&2; done
    if [[ -n $default ]]; then printf 'Select [%s]: ' "$default" >&2; else printf 'Select: ' >&2; fi
    IFS= read -r choice || return 1
    [[ -n $choice ]] || choice=$default
  elif [[ -n $default ]]; then
    choice=$default
  else
    blm_error "Interactive selection is unavailable: $message"
    return 1
  fi

  _blm_is_positive_integer "$choice" || return 2
  ((choice <= ${#options[@]})) || return 2
  printf '%s\n' "${options[$((choice - 1))]}"
}
