#!/usr/bin/env bash

# Bashloom M6E — terminal UX example.
#
# The maintained tour avoids blocking for user input. Interactive prompt APIs
# are demonstrated through explicit defaults so the example remains CI-safe.

set -Eeuo pipefail

ROOT=${BASH_SOURCE[0]%/*}
[[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
ROOT="$(cd -- "$ROOT/.." && pwd)"

source "$ROOT/src/bashloom.sh"

blm_title "M6E terminal UX"

blm_section "Prompt defaults"
name=$(blm_prompt "Name" "Bashloom" </dev/null)
blm_kv selected_name "$name"
if blm_confirm "Continue" yes </dev/null; then
  blm_kv confirmation yes
fi

blm_section "Panel"
blm_panel "Runtime" "mode=${BLM_OUTPUT_MODE:-human}" "tty=$(blm_is_tty && echo yes || echo no)"

blm_section "Table"
blm_table $'Capability\tState' $'prompt\tready' $'progress\tready'

blm_section "Tree"
blm_tree 0 Bashloom
blm_tree 1 ui
blm_tree 2 terminal

blm_section "Progress"
BLM_OUTPUT_MODE=plain blm_progress 1 4 build
BLM_OUTPUT_MODE=plain blm_progress 4 4 build

blm_section "Spinner degradation"
BLM_OUTPUT_MODE=plain blm_spinner "No-op task" bash -c 'exit 0'

blm_success "M6E terminal UX example completed"
