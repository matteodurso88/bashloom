#!/usr/bin/env bash

# Validate that a requested release version matches Bashloom metadata.
# This script does not create tags or releases; it is a gate used by the release
# workflow before publishing release artifacts.

set -Eeuo pipefail

TOOL_DIR=${BASH_SOURCE[0]%/*}
[[ $TOOL_DIR == "${BASH_SOURCE[0]}" ]] && TOOL_DIR=.
REPO_ROOT="$(cd -- "$TOOL_DIR/.." && pwd)"

(($# == 1)) || {
  printf 'Usage: tools/release-check.sh <version>\n' >&2
  exit 2
}

requested=${1#v}

# Bashloom v0.x release tags follow SemVer core + optional prerelease identifiers.
# Build metadata is intentionally not accepted in the release tag contract yet.
[[ $requested =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$ ]] || {
  printf 'Invalid release version: %s\n' "$1" >&2
  exit 2
}

# shellcheck source=src/core/version.sh
source "$REPO_ROOT/src/core/version.sh"

if [[ $BLM_VERSION != "$requested" ]]; then
  printf 'Version mismatch: metadata=%s requested=%s\n' "$BLM_VERSION" "$requested" >&2
  exit 1
fi

printf 'Release version validated: %s\n' "$requested"
