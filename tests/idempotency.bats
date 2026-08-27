#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "change tracking resets and reports aggregate state" {
  run bash -c 'source "$1"; blm_change_reset; blm_changed && exit 10; blm_last_changed && exit 11; _blm_change_begin; _blm_change_mark; blm_changed; a=$?; blm_last_changed; b=$?; printf "%s:%s:%s:%s" "$a" "$b" "$BLM_CHANGED" "$BLM_LAST_CHANGED"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "0:0:1:1" ]
}

@test "ensure directory reports changed only on creation" {
  run bash -c 'source "$1"; d=$(mktemp -d); blm_change_reset; blm_ensure_dir "$d/app"; first=$BLM_LAST_CHANGED; blm_ensure_dir "$d/app"; second=$BLM_LAST_CHANGED; aggregate=$BLM_CHANGED; printf "%s:%s:%s" "$first" "$second" "$aggregate"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:0:1" ]
}

@test "ensure directory reports mode correction as change" {
  run bash -c 'source "$1"; d=$(mktemp -d); mkdir "$d/app"; chmod 755 "$d/app"; blm_change_reset; blm_ensure_dir --mode 700 "$d/app"; first=$BLM_LAST_CHANGED; blm_ensure_dir --mode 700 "$d/app"; second=$BLM_LAST_CHANGED; mode=$(stat -c "%a" "$d/app"); printf "%s:%s:%s" "$first" "$second" "$mode"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:0:700" ]
}

@test "ensure symlink reports creation then no-op" {
  run bash -c 'source "$1"; d=$(mktemp -d); blm_change_reset; blm_ensure_symlink target "$d/link"; first=$BLM_LAST_CHANGED; blm_ensure_symlink target "$d/link"; second=$BLM_LAST_CHANGED; printf "%s:%s:%s" "$first" "$second" "$BLM_CHANGED"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:0:1" ]
}

@test "ensure mode changes only when required" {
  run bash -c 'source "$1"; f=$(mktemp); chmod 600 "$f"; blm_change_reset; blm_ensure_mode 640 "$f"; first=$BLM_LAST_CHANGED; blm_ensure_mode 640 "$f"; second=$BLM_LAST_CHANGED; mode=$(stat -c "%a" "$f"); printf "%s:%s:%s" "$first" "$second" "$mode"; rm -f "$f"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:0:640" ]
}

@test "ensure line appends once and preserves exact line matching" {
  run bash -c 'source "$1"; d=$(mktemp -d); f="$d/config"; printf "alpha=1\n" >"$f"; blm_change_reset; blm_ensure_line "$f" "beta=2"; first=$BLM_LAST_CHANGED; blm_ensure_line "$f" "beta=2"; second=$BLM_LAST_CHANGED; count=0; while IFS= read -r line; do [[ $line == beta=2 ]] && count=$((count + 1)); done <"$f"; printf "%s:%s:%s:%s" "$first" "$second" "$count" "$BLM_CHANGED"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:0:1:1" ]
}

@test "ensure line creates a missing file" {
  run bash -c 'source "$1"; d=$(mktemp -d); f="$d/config"; blm_ensure_line "$f" "enabled=true"; printf "%s:%s" "$BLM_LAST_CHANGED" "$(cat "$f")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1:enabled=true" ]
}
