#!/usr/bin/env bats

setup() {
  export BASHLOOM_ENTRYPOINT="$BATS_TEST_DIRNAME/../src/bashloom.sh"
}

@test "APT availability requires all supported commands" {
  run bash -c '
    source "$1"
    d=$(mktemp -d); mkdir "$d/bin"
    for c in apt-get dpkg-query apt-cache; do printf "#!/usr/bin/env bash\nexit 0\n" >"$d/bin/$c"; chmod +x "$d/bin/$c"; done
    PATH="$d/bin" blm_apt_available
    s=$?
    rm -rf "$d"
    exit "$s"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "APT install forwards validated argv and never injects sudo" {
  run bash -c '
    source "$1"
    d=$(mktemp -d); mkdir "$d/bin"
    cat >"$d/bin/apt-get" <<"EOF"
#!/usr/bin/env bash
printf "<%s>" "$@"
EOF
    printf "#!/usr/bin/env bash\nexit 0\n" >"$d/bin/dpkg-query"
    printf "#!/usr/bin/env bash\nexit 0\n" >"$d/bin/apt-cache"
    chmod +x "$d/bin/"*
    PATH="$d/bin:$PATH"
    blm_apt_install curl ca-certificates
    rm -rf "$d"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "<install><-y><--><curl><ca-certificates>" ]
}

@test "APT mutation honors Bashloom dry-run" {
  run bash -c '
    source "$1"
    d=$(mktemp -d); mkdir "$d/bin"
    for c in apt-get dpkg-query apt-cache; do printf "#!/usr/bin/env bash\nprintf executed >>\"$d/hit\"\n" >"$d/bin/$c"; chmod +x "$d/bin/$c"; done
    PATH="$d/bin:$PATH" BLM_DRY_RUN=1 blm_apt_remove curl >/dev/null
    test ! -e "$d/hit"
    s=$?
    rm -rf "$d"
    exit "$s"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
}

@test "APT package operands reject option injection" {
  run bash -c 'source "$1"; blm_apt_install --dangerous' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 2 ]
}

@test "APT installed predicate and versions preserve query semantics" {
  run bash -c '
    source "$1"
    d=$(mktemp -d); mkdir "$d/bin"
    printf "#!/usr/bin/env bash\nexit 0\n" >"$d/bin/apt-get"
    cat >"$d/bin/dpkg-query" <<"EOF"
#!/usr/bin/env bash
case "$*" in
  *Status*installed*) printf "installed ok installed" ;;
  *Version*installed*) printf "1.2.3\n" ;;
  *) exit 1 ;;
esac
EOF
    cat >"$d/bin/apt-cache" <<"EOF"
#!/usr/bin/env bash
printf "demo:\n  Installed: 1.2.3\n  Candidate: 1.3.0\n"
EOF
    chmod +x "$d/bin/"*
    PATH="$d/bin:$PATH"
    blm_apt_is_installed installed; installed=$?
    iv=$(blm_apt_installed_version installed)
    cv=$(blm_apt_candidate_version demo)
    printf "%s|%s|%s" "$installed" "$iv" "$cv"
    rm -rf "$d"
  ' _ "$BASHLOOM_ENTRYPOINT"
  [ "$status" -eq 0 ]
  [ "$output" = "0|1.2.3|1.3.0" ]
}
