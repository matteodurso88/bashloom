#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
  export BASHLOOM_LOADER="$BATS_TEST_DIRNAME/../src/bashloom-loader.sh"
}

@test "integration groups load selectively and idempotently" {
  run bash -c 'source "$1"; blm_load git docker network systemd integrations; blm_load integrations; declare -F blm_git_root >/dev/null; declare -F blm_docker_compose >/dev/null; declare -F blm_dns_resolves >/dev/null; declare -F blm_systemd_is_active >/dev/null' _ "$BASHLOOM_LOADER"
  [ "$status" -eq 0 ]
}

@test "Git adapter reports root branch and dirty state" {
  run bash -c 'source "$1"; d=$(mktemp -d); git -C "$d" init -q; git -C "$d" config user.email test@example.invalid; git -C "$d" config user.name Test; printf one >"$d/file"; git -C "$d" add file; git -C "$d" commit -qm init; root=$(blm_git_root "$d"); branch=$(blm_git_current_branch "$d"); blm_git_is_clean "$d"; clean=$?; printf two >>"$d/file"; blm_git_is_clean "$d"; dirty=$?; printf "%s|%s|%s|%s" "$root" "$branch" "$clean" "$dirty"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"|0|1" ]]
}

@test "Git require clean returns failure without exiting the caller" {
  run bash -c 'source "$1"; d=$(mktemp -d); git -C "$d" init -q; printf dirty >"$d/file"; blm_git_require_clean "$d" >/dev/null 2>&1; s=$?; printf "%s" "$s"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "systemd adapter preserves systemctl status and arguments" {
  run bash -c 'source "$1"; d=$(mktemp -d); mkdir "$d/bin"; cat >"$d/bin/systemctl" <<"EOF"
#!/usr/bin/env bash
printf "%s\n" "$*" >>"$SYSTEMCTL_LOG"
[[ $1 == is-active ]] && exit 0
[[ $1 == restart ]] && exit 17
exit 0
EOF
chmod +x "$d/bin/systemctl"; export SYSTEMCTL_LOG="$d/log"; PATH="$d/bin:$PATH"; blm_systemd_is_active demo.service; active=$?; blm_systemd_restart demo.service >/dev/null 2>&1; restart=$?; printf "%s:%s:%s" "$active" "$restart" "$(tr "\n" ";" <"$d/log")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [[ "$output" == "0:17:"* ]]
  [[ "$output" == *"is-active --quiet -- demo.service;"* ]]
  [[ "$output" == *"restart -- demo.service;"* ]]
}

@test "systemd wait delegates deadline behavior to blm_wait_for" {
  run bash -c 'source "$1"; attempts=0; blm_systemd_is_active() { attempts=$((attempts + 1)); ((attempts >= 2)); }; blm_systemd_wait_active --timeout 2 --interval 0 demo.service; printf "%s" "$attempts"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}

@test "Docker Compose adapter forwards argv without eval" {
  run bash -c 'source "$1"; d=$(mktemp -d); mkdir "$d/bin"; cat >"$d/bin/docker" <<"EOF"
#!/usr/bin/env bash
if [[ $1 == compose && $2 == version ]]; then exit 0; fi
printf "<%s>" "$@"
EOF
chmod +x "$d/bin/docker"; PATH="$d/bin:$PATH"; out=$(blm_docker_compose run --rm svc "arg with spaces"); printf "%s" "$out"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "<compose><run><--rm><svc><arg with spaces>" ]
}

@test "network DNS predicate uses getent status" {
  run bash -c 'source "$1"; d=$(mktemp -d); mkdir "$d/bin"; cat >"$d/bin/getent" <<"EOF"
#!/usr/bin/env bash
[[ $2 == good.example ]]
EOF
chmod +x "$d/bin/getent"; PATH="$d/bin:$PATH"; blm_dns_resolves good.example; good=$?; blm_dns_resolves bad.example; bad=$?; printf "%s:%s" "$good" "$bad"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "0:1" ]
}

@test "HTTP readiness adapter preserves curl failures and can be polled" {
  run bash -c 'source "$1"; d=$(mktemp -d); mkdir "$d/bin"; cat >"$d/bin/curl" <<"EOF"
#!/usr/bin/env bash
count=0
[[ -f $CURL_COUNT ]] && count=$(cat "$CURL_COUNT")
count=$((count + 1))
printf "%s" "$count" >"$CURL_COUNT"
((count >= 2))
EOF
chmod +x "$d/bin/curl"; export CURL_COUNT="$d/count"; PATH="$d/bin:$PATH"; blm_wait_http --timeout 2 --interval 0 https://example.invalid; printf "%s" "$(cat "$d/count")"; rm -rf "$d"' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
}
