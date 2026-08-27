#!/usr/bin/env bash

# Status helpers render through the configured Bashloom output mode.
#
# These public functions intentionally contain almost no policy themselves: the
# common renderer owns stream selection, color capability and JSON/plain/human
# formatting so every status family stays semantically aligned.

# Public API: blm_info
# Purpose: Emit an informational status record.
# Usage: blm_info <message...>
# Returns: Renderer status.
# Output: stdout; human label INFO, semantic JSON level `info`.
# Side effects: None beyond output.
blm_info() {
  _blm_emit_status stdout info INFO '\033[36m' "$@"
}

# Public API: blm_success
# Purpose: Emit a successful-completion status record.
# Usage: blm_success <message...>
# Returns: Renderer status.
# Output: stdout; human label OK, semantic JSON level `success`.
# Side effects: None beyond output.
blm_success() {
  _blm_emit_status stdout success OK '\033[32m' "$@"
}

# Public API: blm_warn
# Purpose: Emit a warning record without changing caller control flow.
# Usage: blm_warn <message...>
# Returns: Renderer status; warning itself is not a non-zero return condition.
# Output: stderr; human label WARN, semantic JSON level `warn`.
# Side effects: None beyond output.
blm_warn() {
  _blm_emit_status stderr warn WARN '\033[33m' "$@"
}

# Public API: blm_error
# Purpose: Render an error record; callers decide the status/exit behavior.
# Usage: blm_error <message...>
# Returns: Renderer status, normally 0 when the error was printed successfully.
# Output: stderr; human label ERROR, semantic JSON level `error`.
# Side effects: None beyond output.
# Important: This function does not itself return failure merely because the
# semantic record is an error. Use blm_fail/blm_usage_error when status signaling
# is required.
blm_error() {
  _blm_emit_status stderr error ERROR '\033[31m' "$@"
}
