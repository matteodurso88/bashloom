#!/usr/bin/env bash

# Bashloom v0.1 RC — terminal UX showcase.
#
# Run directly from a real terminal for animation/full-screen paths. In CI or a
# pipe, the same APIs degrade deterministically and never block for input.

set -Eeuo pipefail

ROOT=${BASH_SOURCE[0]%/*}
[[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
ROOT="$(cd -- "$ROOT/.." && pwd)"

source "$ROOT/src/bashloom.sh"

BLM_UI_STYLE=rich
BLM_UI_CHARSET=${BLM_UI_CHARSET:-auto}
BLM_UI_THEME=${BLM_UI_THEME:-default}

blm_title "v0.1 RC terminal UX showcase"

if blm_is_tty; then
  blm_success "Interactive terminal detected: rich rendering enabled"
else
  blm_warn "stdout is not a TTY: showing deterministic fallback output"
fi

blm_section "Theme registry"
blm_kv theme "$(blm_ui_theme)"
blm_kv spinner-style "$(blm_ui_style spinner)"
blm_kv progress-style "$(blm_ui_style progress)"
blm_kv panel-style "$(blm_ui_style panel)"

blm_section "Panel variants"
blm_panel --style rounded "Rounded" "default rich border" "width-aware: 漢字"
blm_panel --style square "Square" "classic box drawing"
blm_panel --style double "Double" "strong section boundary"
blm_panel --style minimal "Minimal" "no border"

blm_section "Table variants"
for table_style in unicode ascii compact minimal; do
  printf 'style=%s\n' "$table_style"
  blm_table --style "$table_style" \
    $'Capability\tStatus\tMode' \
    $'Display width\tready\tUnicode 漢' \
    $'Progress\tready\tvariants' \
    $'TUI\tready\tfull-screen'
done

blm_section "Topology-aware tree"
blm_tree_view \
  "Bashloom" \
  $'\tcore' \
  $'\tsystem' \
  $'\tintegrations' \
  $'\tui' \
  $'\t\ttheme-registry' \
  $'\t\twidth-aware-rendering' \
  $'\t\tfull-screen-tui'

blm_section "Progress variants"
for progress_style in blocks bar thin dots percent; do
  for current in 0 50 100; do
    blm_progress --style "$progress_style" "$current" 100 "$progress_style"
    if blm_is_tty; then sleep 0.03; fi
  done
done

blm_section "Spinner variants"
for spinner_style in braille line dots pulse; do
  blm_spinner --style "$spinner_style" "$spinner_style spinner" bash -c 'sleep 0.15; exit 0'
done

blm_section "ASCII theme preview"
BLM_UI_THEME=ascii blm_panel "Portable mode" "No Unicode required" "Same public API"

_tui_demo() {
  local size
  blm_tui_clear
  size=$(blm_tui_size)
  blm_tui_move 2 4
  printf 'Bashloom full-screen TUI foundation'
  blm_tui_move 4 4
  printf 'terminal size: %s' "$size"
  blm_tui_move 6 4
  printf 'alternate screen + cursor lifecycle restored automatically'
  sleep 0.35
}

blm_section "Full-screen TUI"
if blm_tui_available; then
  blm_tui_run _tui_demo
  blm_success "TUI lifecycle completed"
else
  blm_info "TUI unavailable in this non-interactive environment: expected fallback"
fi

blm_success "Terminal UX showcase completed"
