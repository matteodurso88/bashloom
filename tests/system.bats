#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
  # shellcheck source=src/core/version.sh
  source "$BATS_TEST_DIRNAME/../src/core/version.sh"
  export EXPECTED_BASHLOOM_VERSION=$BLM_VERSION
}

@test "path helpers are lexical and dependency-free" {
  run bash -c 'source "$1"; blm_path_dirname "/a/b/c"; blm_path_basename "/a/b/c/"; blm_path_join "/a/" "/b" "c"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = $'/a/b\nc\n/a/b/c' ]
}

@test "temporary file is created with restrictive permissions" {
  run bash -c 'source "$1"; f=$(blm_temp_file); stat -c "%a" "$f"; rm -f "$f"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "600" ]
}

@test "temporary directory is created with restrictive permissions" {
  run bash -c 'source "$1"; d=$(blm_temp_dir); stat -c "%a" "$d"; rmdir "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "700" ]
}

@test "ensure directory is idempotent" {
  run bash -c 'source "$1"; d=$(mktemp -d); blm_ensure_dir "$d/a/b"; blm_ensure_dir "$d/a/b"; [[ -d "$d/a/b" ]]; s=$?; rm -rf "$d"; exit "$s"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "ensure symlink is idempotent and rejects conflicting target" {
  run bash -c 'source "$1"; d=$(mktemp -d); blm_ensure_symlink target "$d/link"; blm_ensure_symlink target "$d/link"; blm_ensure_symlink other "$d/link" >/dev/null 2>&1; s=$?; rm -rf "$d"; exit "$s"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
}

@test "atomic write replaces content and preserves existing mode" {
  run bash -c 'source "$1"; d=$(mktemp -d); f="$d/file"; printf old >"$f"; chmod 640 "$f"; blm_atomic_write "$f" printf new; printf "%s:%s" "$(cat "$f")" "$(stat -c "%a" "$f")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "new:640" ]
}

@test "atomic write leaves destination untouched when producer fails" {
  run bash -c 'source "$1"; d=$(mktemp -d); f="$d/file"; printf old >"$f"; blm_atomic_write "$f" bash -c "printf broken; exit 7"; s=$?; printf "%s:%s" "$s" "$(cat "$f")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "7:old" ]
}

@test "permission requirements report access state" {
  run bash -c 'source "$1"; f=$(mktemp); chmod 600 "$f"; blm_require_readable "$f"; blm_require_writable "$f"; rm -f "$f"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "entrypoint sourcing does not require external dirname" {
  run bash -c 'PATH=/nonexistent; source "$1"; printf "%s" "$BLM_VERSION"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "$EXPECTED_BASHLOOM_VERSION" ]
}
