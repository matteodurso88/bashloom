#!/usr/bin/env bats

setup() {
  REPO_ROOT=$(cd -- "$BATS_TEST_DIRNAME/.." && pwd)
  TEST_DIR=$(mktemp -d)
}

teardown() {
  rm -rf -- "$TEST_DIR"
}

@test "selective loader loads runtime dependencies but not unrelated state" {
  run bash -c '
    source "$1/src/bashloom-loader.sh"
    blm_load runtime
    type blm_run >/dev/null 2>&1
    type blm_step >/dev/null 2>&1
    type blm_require_command >/dev/null 2>&1
    ! type blm_state_set >/dev/null 2>&1
  ' _ "$REPO_ROOT"
  [ "$status" -eq 0 ]
}

@test "selective loader resolves dependencies and is idempotent" {
  run bash -c '
    source "$1/src/bashloom-loader.sh"
    blm_load state logging state logging
    type blm_state_set >/dev/null 2>&1
    type blm_atomic_write >/dev/null 2>&1
    type blm_log >/dev/null 2>&1
  ' _ "$REPO_ROOT"
  [ "$status" -eq 0 ]
}

@test "selective loader rejects unknown module" {
  run bash -c 'source "$1/src/bashloom-loader.sh"; blm_load unknown' _ "$REPO_ROOT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown module: unknown"* ]]
}

@test "full entrypoint still exposes the complete runtime" {
  run bash -c '
    source "$1/src/bashloom.sh"
    type blm_run >/dev/null 2>&1
    type blm_retry >/dev/null 2>&1
    type blm_atomic_write >/dev/null 2>&1
    type blm_state_set >/dev/null 2>&1
    type blm_log >/dev/null 2>&1
  ' _ "$REPO_ROOT"
  [ "$status" -eq 0 ]
}

@test "installer deploys a sourceable runtime under a prefix" {
  prefix="$TEST_DIR/prefix"
  run bash "$REPO_ROOT/tools/install.sh" --prefix "$prefix"
  [ "$status" -eq 0 ]
  [ -f "$prefix/lib/bashloom/bashloom.sh" ]
  [ -f "$prefix/lib/bashloom/bashloom-loader.sh" ]

  run bash -c 'source "$1/lib/bashloom/bashloom.sh"; printf "%s\n" "$BLM_VERSION"' _ "$prefix"
  [ "$status" -eq 0 ]
  [ "$output" = "0.0.0-dev" ]
}

@test "installer refuses overwrite unless force is explicit" {
  prefix="$TEST_DIR/prefix"
  run bash "$REPO_ROOT/tools/install.sh" --prefix "$prefix"
  [ "$status" -eq 0 ]

  run bash "$REPO_ROOT/tools/install.sh" --prefix "$prefix"
  [ "$status" -eq 1 ]

  run bash "$REPO_ROOT/tools/install.sh" --prefix "$prefix" --force
  [ "$status" -eq 0 ]
}

@test "vendor helper creates a self-contained Bashloom copy" {
  destination="$TEST_DIR/project/vendor/bashloom"
  run bash "$REPO_ROOT/tools/vendor.sh" --destination "$destination"
  [ "$status" -eq 0 ]
  [ -f "$destination/bashloom.sh" ]
  [ -f "$destination/bashloom-loader.sh" ]

  run bash -c 'source "$1/bashloom-loader.sh"; blm_load core; printf "%s\n" "$BLM_VERSION"' _ "$destination"
  [ "$status" -eq 0 ]
  [ "$output" = "0.0.0-dev" ]
}

@test "release gate validates metadata and rejects mismatched version" {
  run bash "$REPO_ROOT/tools/release-check.sh" 0.0.0-dev
  [ "$status" -eq 0 ]

  run bash "$REPO_ROOT/tools/release-check.sh" 0.1.0
  [ "$status" -eq 1 ]
  [[ "$output" == *"Version mismatch"* ]]
}
