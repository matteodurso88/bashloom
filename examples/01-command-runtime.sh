#!/usr/bin/env bash

# Bashloom example: command runtime (M1).
#
# Run from the repository root:
#   bash examples/01-command-runtime.sh

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"

source "$REPO_ROOT/src/bashloom.sh"

printf 'Bashloom %s - command runtime example\n\n' "$BLM_VERSION"

blm_step "Run a successful command" printf 'Hello from Bashloom\n'

if blm_run bash -c 'exit 42'; then
  blm_error "Unexpected success"
  exit 1
else
  status=$?
  printf 'Preserved exit status: %d\n' "$status"
  [[ $status -eq 42 ]]
fi

marker="${TMPDIR:-/tmp}/bashloom-example-dry-run.$$"
blm_run --dry-run touch "$marker"
[[ ! -e $marker ]]

BLM_DRY_RUN=1 blm_run touch "$marker"
[[ ! -e $marker ]]

blm_success "M1 example completed"
