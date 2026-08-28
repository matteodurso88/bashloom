#!/usr/bin/env bash

# Display-width helpers for Unicode-aware terminal layout.
#
# Bash has no native wcwidth primitive. Bashloom therefore uses Python's
# standard unicodedata module when available and falls back deterministically to
# Bash character count when it is not. The fallback remains dependency-free and
# safe for ASCII/minimal environments.

_blm_display_width_fallback() {
  (($# == 1)) || return 2
  printf '%s\n' "${#1}"
}

_blm_display_width_python() {
  (($# == 1)) || return 2
  command -v python3 >/dev/null 2>&1 || return 127
  python3 - "$1" <<'PY'
import sys
import unicodedata

text = sys.argv[1]
width = 0
for ch in text:
    category = unicodedata.category(ch)
    if category in {"Cc", "Cf"}:
        continue
    if unicodedata.combining(ch):
        continue
    width += 2 if unicodedata.east_asian_width(ch) in {"W", "F"} else 1
print(width)
PY
}

# Public API: blm_display_width
# Purpose: Report the terminal display width of a string in character cells.
# Usage: blm_display_width <text>
# Returns: 0 on success; 2 for invalid arguments.
# Output: One non-negative integer on stdout.
# Dependencies: Uses python3 + standard unicodedata when available; otherwise
#               falls back to Bash character count.
# Side effects: None.
# Portability: The fallback is deterministic but cannot fully model combining
#              or East Asian wide characters.
blm_display_width() {
  (($# == 1)) || return 2
  local measured
  if measured=$(_blm_display_width_python "$1" 2>/dev/null); then
    printf '%s\n' "$measured"
  else
    _blm_display_width_fallback "$1"
  fi
}

_blm_pad_right() {
  (($# == 2)) || return 2
  local target=$1 text=$2 width padding
  _blm_is_nonnegative_integer "$target" || return 2
  width=$(blm_display_width "$text") || return $?
  ((width <= target)) || {
    printf '%s' "$text"
    return 0
  }
  padding=$((target - width))
  printf '%s%s' "$text" "$(_blm_repeat_glyph ' ' "$padding")"
}
