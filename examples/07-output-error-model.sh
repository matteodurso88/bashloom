#!/usr/bin/env bash

# Bashloom example: output and error model.
#
# Demonstrates presentation helpers, runtime diagnostics and explicit error
# returns without exiting the caller shell.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

blm_title "Bashloom output and error model"
blm_section "Runtime diagnostics"
blm_diagnostics

blm_section "Explicit error status"
if blm_fail 17 "simulated recoverable failure"; then
  :
else
  status=$?
  printf 'Recovered from Bashloom status: %s\n' "$status"
fi

blm_section "Usage error"
if blm_usage_error "simulated invalid arguments"; then
  :
else
  status=$?
  printf 'Usage error status: %s\n' "$status"
fi

printf '\nPlain presentation:\n'
BLM_OUTPUT_MODE=plain blm_title "Plain title"
BLM_OUTPUT_MODE=plain blm_section "Plain section"

printf '\nJSON presentation:\n'
BLM_OUTPUT_MODE=json blm_title "JSON title"
BLM_OUTPUT_MODE=json blm_section "JSON section"
BLM_OUTPUT_MODE=json blm_diagnostics

printf '\nOutput/error example completed.\n'
