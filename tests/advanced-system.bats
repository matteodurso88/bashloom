#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "sha256 checksum returns only the digest" {
  run bash -c 'source "$1"; d=$(mktemp -d); printf abc >"$d/f"; blm_checksum_sha256 "$d/f"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" ]
}

@test "backup preserves source and refuses overwrite" {
  run bash -c 'source "$1"; d=$(mktemp -d); printf original >"$d/source"; blm_backup "$d/source" "$d/backup"; first=$BLM_LAST_CHANGED; blm_backup "$d/source" "$d/backup" >/dev/null 2>&1; second=$?; printf "%s:%s:%s" "$first" "$second" "$(cat "$d/backup")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:1:original" ]
}

@test "safe copy refuses an existing destination" {
  run bash -c 'source "$1"; d=$(mktemp -d); printf one >"$d/a"; printf two >"$d/b"; blm_safe_copy "$d/a" "$d/b" >/dev/null 2>&1; s=$?; printf "%s:%s" "$s" "$(cat "$d/b")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:two" ]
}

@test "safe move moves only to an absent destination" {
  run bash -c 'source "$1"; d=$(mktemp -d); printf one >"$d/a"; blm_safe_move "$d/a" "$d/b"; printf "%s:%s:%s" "$BLM_LAST_CHANGED" "$([[ ! -e $d/a ]] && echo yes)" "$(cat "$d/b")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:yes:one" ]
}

@test "directory lock is exclusive and releasable" {
  run bash -c 'source "$1"; d=$(mktemp -d); lock="$d/lock"; blm_lock_acquire "$lock"; blm_lock_acquire "$lock" >/dev/null 2>&1; conflict=$?; blm_lock_release "$lock"; printf "%s:%s" "$conflict" "$([[ ! -d $lock ]] && echo released)"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:released" ]
}

@test "with lock preserves command status and releases lock" {
  run bash -c 'source "$1"; d=$(mktemp -d); lock="$d/lock"; blm_with_lock "$lock" bash -c "exit 19"; s=$?; printf "%s:%s" "$s" "$([[ ! -d $lock ]] && echo released)"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "19:released" ]
}

@test "ensure owner is a no-op for the current owner and group" {
  run bash -c 'source "$1"; d=$(mktemp -d); f="$d/f"; : >"$f"; owner=$(stat -c "%U:%G" "$f"); blm_ensure_owner "$owner" "$f"; printf "%s" "$BLM_LAST_CHANGED"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "XDG helpers honor overrides and defaults" {
  run bash -c 'source "$1"; HOME=/home/test XDG_CONFIG_HOME=/custom/config; printf "%s|%s|%s|%s" "$(blm_xdg_config_home)" "$(blm_xdg_data_home)" "$(blm_xdg_cache_home)" "$(blm_xdg_state_home)"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "/custom/config|/home/test/.local/share|/home/test/.cache|/home/test/.local/state" ]
}

@test "XDG runtime dir requires an explicit environment value" {
  run bash -c 'source "$1"; unset XDG_RUNTIME_DIR; blm_xdg_runtime_dir >/dev/null 2>&1' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 1 ]
}
