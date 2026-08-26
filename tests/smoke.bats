#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "entrypoint can be sourced" {
  run bash -c 'source "$1"; printf "%s" "$BLM_VERSION"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "0.0.0-dev" ]
}

@test "sourcing does not enable errexit" {
  run bash -c 'set +e; source "$1"; [[ $- == *e* ]] && exit 1 || exit 0' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "sourcing does not enable nounset" {
  run bash -c 'set +u; source "$1"; [[ $- == *u* ]] && exit 1 || exit 0' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "require command succeeds for bash" {
  run bash -c 'source "$1"; blm_require_command bash' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "require command fails for a missing command" {
  run bash -c 'source "$1"; blm_require_command __bashloom_missing_command__' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Required command not found"* ]]
}

@test "NO_COLOR forces plain status output" {
  run bash -c 'export NO_COLOR=1; source "$1"; blm_success "ready"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "[OK] ready" ]
}
