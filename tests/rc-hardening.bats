#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "JSON output escapes representable C0 controls" {
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=json blm_kv $'"'"'k\001'"'"' $'"'"'v\013'"'"'' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = '{"key":"k\u0001","value":"v\u000b"}' ]
}

@test "numeric mode validation rejects non-octal input before mutation" {
  target="$BATS_TEST_TMPDIR/bad-mode"
  run bash -c 'source "$1"; blm_ensure_dir --mode 0999 "$2"' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 2 ]
  [ ! -e "$target" ]
}

@test "numeric mode normalization accepts conventional leading zero" {
  target="$BATS_TEST_TMPDIR/mode-dir"
  run bash -c 'source "$1"; blm_ensure_dir --mode 0750 "$2"; stat -c "%a" "$2"' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 0 ]
  [ "$output" = "750" ]
}

@test "ensure line rejects embedded newline without touching destination" {
  target="$BATS_TEST_TMPDIR/lines"
  run bash -c 'source "$1"; blm_ensure_line "$2" $'"'"'one\ntwo'"'"'' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 2 ]
  [ ! -e "$target" ]
}

@test "atomic write remains replacement atomicity not implicit durability API" {
  target="$BATS_TEST_TMPDIR/atomic"
  printf 'old\n' >"$target"
  chmod 0640 "$target"
  run bash -c 'source "$1"; producer() { printf "new\n"; }; blm_atomic_write "$2" producer; printf "%s|" "$(cat "$2")"; stat -c "%a" "$2"' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 0 ]
  [ "$output" = "new|640" ]
}

@test "timeout process-group path terminates external-command descendants when setsid exists" {
  command -v setsid >/dev/null 2>&1 || skip "setsid unavailable"
  pidfile="$BATS_TEST_TMPDIR/descendant.pid"
  run bash -c '
    source "$1"
    if blm_timeout --timeout 1 --grace 0 -- bash -c '\''sleep 30 & echo $! >"$1"; wait'\'' _ "$2" 2>/dev/null; then
      exit 90
    else
      status=$?
    fi
    child=$(cat "$2")
    alive=0
    if [[ -r /proc/$child/stat ]]; then
      read -r _ _ state _ <"/proc/$child/stat" || true
      [[ ${state:-Z} != Z ]] && alive=1
    fi
    printf "%s|%s" "$status" "$alive"
  ' _ "$BASHLOOM_ENTRYPOINT" "$pidfile"
  [ "$status" -eq 0 ]
  [ "$output" = "124|0" ]
}

@test "timeout retains shell-function compatibility fallback" {
  run bash -c '
    source "$1"
    f() { sleep 5; }
    if blm_timeout --timeout 1 --grace 0 -- f 2>/dev/null; then exit 90; else printf "%s" "$?"; fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "124" ]
}

@test "directory locks deliberately do not auto-recover stale paths" {
  lock="$BATS_TEST_TMPDIR/stale.lock"
  mkdir "$lock"
  run bash -c 'source "$1"; blm_lock_acquire "$2"' _ "$BASHLOOM_ENTRYPOINT" "$lock"
  [ "$status" -eq 1 ]
  [ -d "$lock" ]
}

@test "config comments remain intentionally first-byte strict" {
  config="$BATS_TEST_TMPDIR/config"
  printf ' #not-a-comment\n' >"$config"
  run bash -c 'source "$1"; blm_config_validate "$2"' _ "$BASHLOOM_ENTRYPOINT" "$config"
  [ "$status" -eq 1 ]
}

@test "log file parent is never created implicitly" {
  log="$BATS_TEST_TMPDIR/missing/log.txt"
  run bash -c 'source "$1"; BLM_OUTPUT_MODE=plain BLM_LOG_FILE="$2" blm_log info test >/dev/null 2>&1' _ "$BASHLOOM_ENTRYPOINT" "$log"
  [ "$status" -ne 0 ]
  [ ! -d "$BATS_TEST_TMPDIR/missing" ]
}
