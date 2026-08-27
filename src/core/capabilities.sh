#!/usr/bin/env bash

# Terminal and command capability predicates.
#
# These helpers are intentionally side-effect free. They expose environmental
# facts without caching them so a caller that changes PATH, TERM or NO_COLOR
# receives the current state on the next call.

# Public API: blm_has_command
# Purpose: Test whether a command name resolves through the current PATH.
# Usage: blm_has_command <name>
# Returns:
#   0  command -v resolves the supplied name.
#   non-zero  the command cannot be resolved.
# Output: None; command lookup output is suppressed.
# Side effects: None.
blm_has_command() {
  command -v "$1" >/dev/null 2>&1
}

# Public API: blm_is_tty
# Purpose: Test whether Bashloom's stdout is currently attached to a terminal.
# Usage: blm_is_tty
# Returns: 0 for a terminal stdout, 1 for pipes/files/non-interactive output.
# Output: None.
# Side effects: None.
# Notes: stdout is authoritative because most human-facing Bashloom rendering
# is emitted there; stderr-specific helpers still follow the same UI policy.
blm_is_tty() {
  [[ -t 1 ]]
}

# Public API: blm_color_enabled
# Purpose: Decide whether ANSI color is appropriate for human output now.
# Usage: blm_color_enabled
# Returns: 0 when color may be emitted, 1 when it must be suppressed.
# Output: None.
# Side effects: None.
# Policy:
#   - any non-empty NO_COLOR disables color;
#   - TERM=dumb disables color;
#   - non-TTY stdout disables color.
# This predicate does not force color and does not inspect terminal databases.
blm_color_enabled() {
  [[ -z "${NO_COLOR:-}" ]] || return 1
  [[ "${TERM:-}" != "dumb" ]] || return 1
  blm_is_tty
}
