#!/usr/bin/env bats

setup() {
  REPO_ROOT=$(cd -- "$BATS_TEST_DIRNAME/.." && pwd)
  source "$REPO_ROOT/src/bashloom.sh"
  TEST_DIR=$(mktemp -d)
}

teardown() {
  rm -rf -- "$TEST_DIR"
}

@test "output mode defaults to human" {
  run blm_output_mode
  [ "$status" -eq 0 ]
  [ "$output" = "human" ]
}

@test "plain status output is deterministic" {
  BLM_OUTPUT_MODE=plain run blm_info "hello world"
  [ "$status" -eq 0 ]
  [ "$output" = "[INFO] hello world" ]
}

@test "json status output escapes message content" {
  BLM_OUTPUT_MODE=json run blm_info 'hello "world"'
  [ "$status" -eq 0 ]
  [ "$output" = '{"level":"info","message":"hello \"world\""}' ]
}

@test "blm_kv supports json machine output" {
  BLM_OUTPUT_MODE=json run blm_kv mode safe
  [ "$status" -eq 0 ]
  [ "$output" = '{"key":"mode","value":"safe"}' ]
}

@test "invalid output mode returns usage-style error" {
  BLM_OUTPUT_MODE=xml run blm_info hello
  [ "$status" -eq 2 ]
  [[ "$output" == *"Invalid BLM_OUTPUT_MODE"* ]]
}

@test "environment helper returns value and fallback" {
  export BLM_TEST_VALUE=present
  run blm_env_get BLM_TEST_VALUE
  [ "$status" -eq 0 ]
  [ "$output" = "present" ]

  unset BLM_TEST_VALUE
  run blm_env_get BLM_TEST_VALUE fallback
  [ "$status" -eq 0 ]
  [ "$output" = "fallback" ]
}

@test "boolean environment helper recognizes true false and invalid values" {
  export BLM_TEST_BOOL=yes
  run blm_env_bool BLM_TEST_BOOL
  [ "$status" -eq 0 ]

  export BLM_TEST_BOOL=off
  run blm_env_bool BLM_TEST_BOOL
  [ "$status" -eq 1 ]

  export BLM_TEST_BOOL=maybe
  run blm_env_bool BLM_TEST_BOOL
  [ "$status" -eq 2 ]
}

@test "safe config reads data without shell evaluation" {
  config="$TEST_DIR/app.conf"
  printf '%s\n' 'NAME=Bashloom' 'PAYLOAD=$(touch /tmp/bashloom-must-not-run)' >"$config"

  run blm_config_get "$config" NAME
  [ "$status" -eq 0 ]
  [ "$output" = "Bashloom" ]

  run blm_config_get "$config" PAYLOAD
  [ "$status" -eq 0 ]
  [ "$output" = '$(touch /tmp/bashloom-must-not-run)' ]
  [ ! -e /tmp/bashloom-must-not-run ]
}

@test "safe config rejects malformed and duplicate keys" {
  config="$TEST_DIR/app.conf"
  printf '%s\n' 'A=1' 'A=2' >"$config"
  run blm_config_get "$config" A
  [ "$status" -eq 1 ]

  printf '%s\n' 'this is not valid' >"$config"
  run blm_config_validate "$config"
  [ "$status" -eq 1 ]
}

@test "state set get update delete are atomic data operations" {
  state="$TEST_DIR/state.env"

  run blm_state_set "$state" phase bootstrap
  [ "$status" -eq 0 ]
  run blm_state_get "$state" phase
  [ "$output" = "bootstrap" ]

  run blm_state_set "$state" phase ready
  [ "$status" -eq 0 ]
  run blm_state_get "$state" phase
  [ "$output" = "ready" ]

  run blm_state_set "$state" count 3
  [ "$status" -eq 0 ]
  run blm_state_delete "$state" phase
  [ "$status" -eq 0 ]
  run blm_state_get "$state" phase missing
  [ "$output" = "missing" ]
  run blm_state_get "$state" count
  [ "$output" = "3" ]
}

@test "state rejects multiline values" {
  state="$TEST_DIR/state.env"
  run blm_state_set "$state" bad $'first\nsecond'
  [ "$status" -eq 2 ]
  [ ! -e "$state" ]
}

@test "logger filters levels and appends stable file records" {
  log="$TEST_DIR/bashloom.log"
  BLM_OUTPUT_MODE=plain BLM_LOG_LEVEL=warn BLM_LOG_FILE="$log" run blm_log info hidden
  [ "$status" -eq 0 ]
  [ ! -e "$log" ]

  BLM_OUTPUT_MODE=plain BLM_LOG_LEVEL=warn BLM_LOG_FILE="$log" run blm_log error failure
  [ "$status" -eq 0 ]
  [[ "$output" == *"[ERROR] failure"* ]]
  [ -f "$log" ]
  grep -q '\[ERROR\] failure$' "$log"
}
