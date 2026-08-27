#!/usr/bin/env bash

# Bashloom M6E.1 — rich terminal rendering showcase.
#
# Run this example directly from a real terminal to see the animated and rich
# rendering paths. In CI or through a pipe the same APIs degrade deterministically.

set -Eeuo pipefail

ROOT=${BASH_SOURCE[0]%/*}
[[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
ROOT="$(cd -- "$ROOT/.." && pwd)"

source "$ROOT/src/bashloom.sh"

BLM_UI_STYLE=rich
BLM_UI_CHARSET=${BLM_UI_CHARSET:-auto}

blm_title "M6E.1 rich terminal showcase"

if blm_is_tty; then
  blm_success "Interactive terminal detected: rich rendering enabled"
else
  blm_warn "stdout is not a TTY: showing deterministic fallback output"
fi

blm_section "Rich panel"
blm_panel "Bashloom runtime" \
  "style=${BLM_UI_STYLE}" \
  "charset=${BLM_UI_CHARSET}" \
  "mode=${BLM_OUTPUT_MODE:-human}"

blm_section "Aligned table"
blm_table \
  $'Capability\tStatus\tMode' \
  $'Progress bar\tready\trich' \
  $'Spinner\tready\tanimated' \
  $'Panels\tready\tauto-width' \
  $'Fallback\tready\tASCII/plain'

blm_section "Tree rendering"
blm_tree 0 Bashloom
blm_tree 1 core
blm_tree 1 system
blm_tree 1 integrations
blm_tree 1 ui
blm_tree 2 terminal
blm_tree 2 rich-rendering

blm_section "Visual progress bar"
for current in 0 10 20 30 40 50 60 70 80 90 100; do
  blm_progress "$current" 100 "Building release"
  if blm_is_tty; then
    sleep 0.05
  fi
done

blm_section "Animated spinner"
blm_spinner "Checking runtime" bash -c 'sleep 1; exit 0'

blm_section "ASCII fallback preview"
BLM_UI_CHARSET=ascii blm_panel "Portable mode" "No Unicode required" "Same API, safe fallback"

blm_success "Rich terminal showcase completed"
