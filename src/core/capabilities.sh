#!/usr/bin/env bash

# Return success when the given command is available in PATH.
blm_has_command() {
  command -v "$1" >/dev/null 2>&1
}

# Return success when stdout is connected to a terminal.
blm_is_tty() {
  [[ -t 1 ]]
}

# Return success when colored output is appropriate for the current context.
#
# NO_COLOR follows the de-facto community convention: any non-empty value
# disables color. TERM=dumb and non-TTY output also disable color.
blm_color_enabled() {
  [[ -z "${NO_COLOR:-}" ]] || return 1
  [[ "${TERM:-}" != "dumb" ]] || return 1
  blm_is_tty
}
