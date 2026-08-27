#!/usr/bin/env bash

# Bashloom M6D — integrations example.
#
# This example is intentionally non-destructive. It demonstrates read-only Git,
# Docker/systemd capability detection and a local resolver check. Operations
# that would restart services or create/remove containers are shown in comments
# rather than executed by the maintained full-tour.
#
# GitHub Actions commonly checks repositories out in detached HEAD state, so
# branch reporting degrades explicitly to `detached` instead of treating that
# perfectly valid CI state as an example failure.

set -Eeuo pipefail

ROOT=${BASH_SOURCE[0]%/*}
[[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
ROOT="$(cd -- "$ROOT/.." && pwd)"

source "$ROOT/src/bashloom.sh"

blm_title "M6D integrations"

blm_section "Git"
repo_root=$(blm_git_root "$ROOT")
blm_kv repository_root "$repo_root"
if branch=$(blm_git_current_branch "$ROOT" 2>/dev/null); then
  blm_kv branch "$branch"
else
  blm_kv branch detached
fi
if blm_git_is_clean "$ROOT"; then
  blm_kv work_tree clean
else
  blm_kv work_tree dirty
fi

blm_section "Docker Compose capability"
if blm_docker_compose_available; then
  blm_kv docker_compose available
else
  blm_kv docker_compose unavailable
fi

# Mutating Compose operations remain explicit and opt-in:
#   blm_docker_compose_up api worker
#   blm_docker_compose_down

blm_section "systemd capability"
if blm_has_command systemctl; then
  blm_kv systemctl available
else
  blm_kv systemctl unavailable
fi

# Mutating service operations remain explicit and opt-in:
#   blm_systemd_restart my-service.service
#   blm_systemd_wait_active --timeout 30 my-service.service

blm_section "Network"
if blm_dns_resolves localhost; then
  blm_kv localhost_resolution ok
else
  blm_kv localhost_resolution unavailable
fi

blm_success "M6D integrations example completed"
