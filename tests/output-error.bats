#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
  export BASHLOOM_VERSION_FILE="$BATS_TEST_DIRNAME/../src/core/version.sh"
  # shellcheck source=src/core/version.sh
  source "$BASHLOOM_VERSION_FILE"
  export EXPECTED_BASHLOOM_VERSION=$BLM_VERSION
}

@test "title and section render human output" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=human; blm_title "Deploy"; blm_section "Database"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"=== Deploy ==="* ]]
  [[ "$output" == *"-- Database --"* ]]
}

@test "title and section render deterministic plain output" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_title "Deploy"; blm_section "Database"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = $'title: Deploy\nsection: Database' ]
}

@test "title and section render JSON records" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=json; blm_title "Deploy"; blm_section "Database"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = $'{"type":"title","message":"Deploy"}\n{"type":"section","message":"Database"}' ]
}

@test "blm_fail reports an error and preserves requested status" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_fail 17 "deployment failed"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 17 ]
  [ "$output" = "[ERROR] deployment failed" ]
}

@test "blm_fail rejects invalid status" {
  run bash -c 'source "$1"; blm_fail 0 "bad"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Invalid failure status"* ]]
}

@test "blm_usage_error returns status 2" {
  run bash -c 'source "$1"; blm_usage_error "bad arguments"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"bad arguments"* ]]
}

@test "diagnostics expose stable keys in plain mode" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain; blm_diagnostics' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"bashloom_version: $EXPECTED_BASHLOOM_VERSION"* ]]
  [[ "$output" == *"bash_version:"* ]]
  [[ "$output" == *"output_mode: plain"* ]]
  [[ "$output" == *"tty: false"* ]]
  [[ "$output" == *"color: false"* ]]
  [[ "$output" == *"ci:"* ]]
}

@test "diagnostics emit machine-readable JSON records" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=json; blm_diagnostics' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"{\"key\":\"bashloom_version\",\"value\":\"$EXPECTED_BASHLOOM_VERSION\"}"* ]]
  [[ "$output" == *'{"key":"output_mode","value":"json"}'* ]]
}
