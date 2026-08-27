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

@test "progress degrades to deterministic non-TTY text" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain blm_progress 2 4 build' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "build: 50% (2/4)" ]
}

@test "progress JSON is structured" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=json blm_progress 1 4 sync' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = '{"type":"progress","label":"sync","current":1,"total":4,"percent":25}' ]
}

@test "table and tree render deterministic plain output" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_table $'"'"'A\tB'"'"'; blm_tree 2 leaf' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "A  B" ]
  [ "${lines[1]}" = "    leaf" ]
}

@test "spinner preserves wrapped command status in non-TTY mode" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_spinner work bash -c "exit 17"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 17 ]
}
