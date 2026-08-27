#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "blm_run preserves command exit status under caller errexit" {
  run bash -c '
    set -e
    export NO_COLOR=1
    source "$1"
    if blm_run bash -c "exit 37"; then
      exit 90
    else
      status=$?
    fi
    printf "%s" "$status"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "37" ]
}

@test "blm_run dry-run does not execute the command" {
  target="$BATS_TEST_TMPDIR/not-created"
  run bash -c '
    export NO_COLOR=1
    source "$1"
    blm_run --dry-run -- touch "$2"
    [[ ! -e $2 ]]
  ' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY-RUN"* ]]
}

@test "blm_step returns the wrapped command status" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    if blm_step "Expected failure" bash -c "exit 23"; then
      exit 90
    else
      exit $?
    fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 23 ]
}

@test "blm_retry can succeed on a later attempt" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    tries=0
    flaky() {
      tries=$((tries + 1))
      ((tries >= 3))
    }
    blm_retry --attempts 4 --delay 0 -- flaky
    printf "TRIES=%s" "$tries"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TRIES=3" ]]
}

@test "blm_retry returns the final command status" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    if blm_retry --attempts 2 --delay 0 -- bash -c "exit 19"; then
      exit 90
    else
      exit $?
    fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 19 ]
}

@test "blm_wait_for succeeds when the condition becomes true" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    tries=0
    ready() {
      tries=$((tries + 1))
      ((tries >= 3))
    }
    blm_wait_for --timeout 2 --interval 0 -- ready
    printf "TRIES=%s" "$tries"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"TRIES=3" ]]
}

@test "blm_wait_for uses status 124 on timeout" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    if blm_wait_for --timeout 0 --interval 0 -- bash -c "exit 5"; then
      exit 90
    else
      exit $?
    fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 124 ]
}

@test "cleanup runs in LIFO order and preserves arguments" {
  target="$BATS_TEST_TMPDIR/cleanup-order"
  run bash -c '
    export NO_COLOR=1
    source "$1"
    target=$2
    record() { printf "%s\n" "$1" >> "$target"; }
    blm_cleanup_add record "first value"
    blm_cleanup_add record "second value"
    blm_cleanup_run
    cat "$target"
  ' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 0 ]
  [ "$output" = $'second value\nfirst value' ]
}

@test "cleanup trap installation refuses to overwrite caller traps" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    trap ":" EXIT
    if blm_cleanup_enable_traps; then
      exit 90
    else
      exit $?
    fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
}

@test "transaction rollback runs registered actions in LIFO order" {
  target="$BATS_TEST_TMPDIR/rollback-order"
  run bash -c '
    export NO_COLOR=1
    source "$1"
    target=$2
    record() { printf "%s\n" "$1" >> "$target"; }
    blm_transaction_begin
    blm_rollback_add record "restore config"
    blm_rollback_add record "restore database"
    blm_transaction_rollback
    cat "$target"
  ' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 0 ]
  [ "$output" = $'restore database\nrestore config' ]
}

@test "transaction commit discards rollback actions" {
  target="$BATS_TEST_TMPDIR/commit-order"
  run bash -c '
    export NO_COLOR=1
    source "$1"
    target=$2
    record() { printf "%s\n" "$1" >> "$target"; }
    blm_transaction_begin
    blm_rollback_add record "must not run"
    blm_transaction_commit
    [[ ! -e $target ]]
  ' _ "$BASHLOOM_ENTRYPOINT" "$target"
  [ "$status" -eq 0 ]
}

@test "blm_timeout returns 124 when the deadline is exceeded" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    if blm_timeout --timeout 1 --grace 0 -- bash -c "sleep 5"; then
      exit 90
    else
      exit $?
    fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 124 ]
}

@test "blm_timeout preserves a command failure before the deadline" {
  run bash -c '
    export NO_COLOR=1
    source "$1"
    if blm_timeout --timeout 5 --grace 0 -- bash -c "exit 31"; then
      exit 90
    else
      exit $?
    fi
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 31 ]
}
