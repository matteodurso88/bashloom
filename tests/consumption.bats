#!/usr/bin/env bats

setup() {
  REPO_ROOT=$(cd -- "$BATS_TEST_DIRNAME/.." && pwd)
  # shellcheck source=src/core/version.sh
  source "$REPO_ROOT/src/core/version.sh"
  CURRENT_VERSION=$BLM_VERSION
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
  [ "$output" = "$CURRENT_VERSION" ]
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

@test "vendor helper creates a pinned self-contained Bashloom bundle" {
  destination="$TEST_DIR/project/vendor/bashloom"
  pin=test-pin-123
  run bash "$REPO_ROOT/tools/vendor.sh" --destination "$destination" --pin "$pin"
  [ "$status" -eq 0 ]
  [ -f "$destination/PIN" ]
  [ -f "$destination/LICENSE" ]
  [ -f "$destination/SHA256SUMS" ]
  [ -f "$destination/src/bashloom.sh" ]
  [ -f "$destination/src/bashloom-loader.sh" ]
  [ "$(cat "$destination/PIN")" = "$pin" ]

  run bash -c 'source "$1/src/bashloom-loader.sh"; blm_load core; printf "%s\n" "$BLM_VERSION"' _ "$destination"
  [ "$status" -eq 0 ]
  [ "$output" = "$CURRENT_VERSION" ]

  run bash "$REPO_ROOT/tools/vendor-verify.sh" "$destination"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Bashloom vendor integrity PASS"* ]]
}

@test "vendor integrity verifier detects modified runtime" {
  destination="$TEST_DIR/project/vendor/bashloom"
  run bash "$REPO_ROOT/tools/vendor.sh" --destination "$destination" --pin test-pin-456
  [ "$status" -eq 0 ]

  printf '\n# consumer mutation\n' >>"$destination/src/bashloom.sh"
  run bash "$REPO_ROOT/tools/vendor-verify.sh" "$destination"
  [ "$status" -ne 0 ]
}

@test "vendor helper refuses overwrite unless force is explicit" {
  destination="$TEST_DIR/project/vendor/bashloom"
  run bash "$REPO_ROOT/tools/vendor.sh" --destination "$destination" --pin first
  [ "$status" -eq 0 ]

  run bash "$REPO_ROOT/tools/vendor.sh" --destination "$destination" --pin second
  [ "$status" -eq 1 ]

  run bash "$REPO_ROOT/tools/vendor.sh" --destination "$destination" --pin second --force
  [ "$status" -eq 0 ]
  [ "$(cat "$destination/PIN")" = second ]
}

@test "release gate validates metadata, v-prefixed RC tag, and mismatch" {
  run bash "$REPO_ROOT/tools/release-check.sh" "$CURRENT_VERSION"
  [ "$status" -eq 0 ]

  run bash "$REPO_ROOT/tools/release-check.sh" "v$CURRENT_VERSION"
  [ "$status" -eq 0 ]

  run bash "$REPO_ROOT/tools/release-check.sh" 999.999.999
  [ "$status" -eq 1 ]
  [[ "$output" == *"Version mismatch"* ]]
}

@test "release gate rejects malformed prerelease and build metadata" {
  run bash "$REPO_ROOT/tools/release-check.sh" 0.1.0-
  [ "$status" -eq 2 ]
  [[ "$output" == *"Invalid release version"* ]]

  run bash "$REPO_ROOT/tools/release-check.sh" 0.1.0-rc1+build
  [ "$status" -eq 2 ]
  [[ "$output" == *"Invalid release version"* ]]
}
