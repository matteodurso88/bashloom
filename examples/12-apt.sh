#!/usr/bin/env bash

# Bashloom v0.1 RC — optional APT integration example.
#
# This example never mutates package state. It detects the APT toolchain, shows
# query behavior and demonstrates install through Bashloom's global dry-run.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"

source "$REPO_ROOT/src/bashloom-loader.sh"
blm_load apt terminal

blm_title "APT integration"

if ! blm_apt_available; then
  blm_info "APT toolchain unavailable on this host; optional integration skipped"
  exit 0
fi

blm_success "APT toolchain detected"

if blm_apt_is_installed bash; then
  version=$(blm_apt_installed_version bash)
  blm_kv bash-installed "$version"
else
  blm_info "bash package not reported as installed by dpkg-query"
fi

if candidate=$(blm_apt_candidate_version bash 2>/dev/null); then
  blm_kv bash-candidate "$candidate"
else
  blm_info "No APT candidate reported for bash"
fi

BLM_DRY_RUN=1 blm_apt_install bash
blm_success "APT example completed without package mutation"
