#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "prompt uses explicit default when non-interactive" {
  run bash -c 'source "$1"; blm_prompt Name fallback </dev/null' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "fallback" ]
}

@test "confirm respects explicit non-interactive defaults" {
  run bash -c 'source "$1"; blm_confirm Deploy yes </dev/null' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  run bash -c 'source "$1"; blm_confirm Deploy no </dev/null' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
}

@test "password refuses non-interactive stdin" {
  run bash -c 'source "$1"; blm_password Secret </dev/null' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
}

@test "select uses explicit default index when non-interactive" {
  run bash -c 'source "$1"; blm_select Mode --default 2 -- safe fast </dev/null' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "fast" ]
}

@test "theme registry resolves stable component defaults" {
  run bash -c 'source "$1"; BLM_UI_THEME=modern; printf "%s/%s/%s\n" "$(blm_ui_theme)" "$(blm_ui_style spinner)" "$(blm_ui_style progress)"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "modern/dots/thin" ]
}

@test "invalid theme and UI style are rejected" {
  run bash -c 'source "$1"; BLM_UI_THEME=broken blm_ui_theme' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
  run bash -c 'source "$1"; BLM_UI_STYLE=broken blm_ui_theme' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
}

@test "component style environment override is validated" {
  run bash -c 'source "$1"; BLM_SPINNER_STYLE=pulse blm_ui_style spinner' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "pulse" ]
  run bash -c 'source "$1"; BLM_SPINNER_STYLE=invalid blm_ui_style spinner' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
}

@test "progress degrades to deterministic non-TTY text" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain blm_progress 2 4 build' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "build: 50% (2/4)" ]
}

@test "progress JSON is structured and reports resolved style" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=json blm_progress 1 4 sync' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = '{"type":"progress","label":"sync","current":1,"total":4,"percent":25,"style":"blocks"}' ]
}

@test "intermediate progress remains success-safe under set -e" {
  run bash -c 'set -e; source "$1"; BLM_OUTPUT_MODE=plain blm_progress 0 4 build; printf "continued\n"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "build: 0% (0/4)" ]
  [ "${lines[1]}" = "continued" ]
}

@test "ASCII progress variants are fixed width and proportional" {
  run bash -c 'source "$1"; BLM_UI_CHARSET=ascii; _blm_progress_bar 50 10 blocks; printf "\n"; _blm_progress_bar 50 10 dots' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "#####-----" ]
  [ "${lines[1]}" = "ooooo....." ]
}

@test "invalid per-call progress style is rejected" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain blm_progress --style nope 1 2 build' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
}

@test "invalid UI charset is rejected" {
  run bash -c 'source "$1"; BLM_UI_CHARSET=broken blm_panel Runtime one' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
}

@test "panel plain output is deterministic" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain blm_panel Runtime one two' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "panel: Runtime" ]
  [ "${lines[1]}" = "  one" ]
  [ "${lines[2]}" = "  two" ]
}

@test "table and legacy tree render deterministic plain output" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_table $'"'"'A\tB'"'"'; blm_tree 2 leaf' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "A  B" ]
  [ "${lines[1]}" = "    leaf" ]
}

@test "display width handles wide and combining Unicode when python is available" {
  if ! command -v python3 >/dev/null 2>&1; then skip "python3 unavailable"; fi
  run bash -c 'source "$1"; printf "%s/%s\n" "$(blm_display_width 漢)" "$(blm_display_width $'"'"'e\u0301'"'"')"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "2/1" ]
}

@test "topology tree infers sibling endings in JSON" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=json; blm_tree_view "root" $'"'"'\tone'"'"' $'"'"'\ttwo'"'"' $'"'"'\t\tleaf'"'"'' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" == *'"depth":1,"last":false,"label":"one"'* ]]
  [[ "${lines[2]}" == *'"depth":1,"last":true,"label":"two"'* ]]
  [[ "${lines[3]}" == *'"depth":2,"last":true,"label":"leaf"'* ]]
}

@test "topology tree rejects malformed depth jumps" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_tree_view "root" $'"'"'\t\tbad'"'"'' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
}

@test "TUI refuses non-interactive execution without terminal mutation" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=human blm_tui_enter </dev/null' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
}

@test "TUI size has deterministic explicit override" {
  run bash -c 'source "$1"; BLM_TUI_COLUMNS=120 BLM_TUI_LINES=40 blm_tui_size' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "120 40" ]
}

@test "spinner preserves wrapped command status in non-TTY mode" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_spinner --style pulse work bash -c "exit 17"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 17 ]
}
