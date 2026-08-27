#!/usr/bin/env bash

# Bashloom full feature tour.
#
# The focused examples are the canonical executable demonstrations for each
# milestone. This orchestrator runs all of them in order so CI and users can
# validate/present the complete implemented surface without duplicating example
# logic in a second large script.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
EXAMPLE_DIR="$(cd -- "$EXAMPLE_DIR" && pwd)"

examples=(
  00-foundation.sh
  01-command-runtime.sh
  02-reliability.sh
  03-system-safety.sh
  04-runtime-state.sh
  05-consumption.sh
  06-idempotency.sh
  07-output-error-model.sh
  08-advanced-system.sh
  09-integrations.sh
  10-terminal-ux.sh
  11-rich-terminal.sh
)

printf '%s\n' '===================================================================='
printf '%s\n' 'Bashloom full feature tour'
printf '%s\n' '===================================================================='

example=""
for example in "${examples[@]}"; do
  printf '\n>>> Running %s\n\n' "$example"
  bash "$EXAMPLE_DIR/$example"
done

printf '\n%s\n' '===================================================================='
printf '%s\n' 'Bashloom full tour completed successfully.'
printf '%s\n' '===================================================================='
