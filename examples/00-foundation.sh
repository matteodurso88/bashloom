#!/usr/bin/env bash

# Bashloom example: foundation primitives.
#
# Demonstrates version metadata, command/TTY/color capabilities and the basic
# status rendering API. No persistent system state is modified.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

printf 'Bashloom version: %s\n' "$BLM_VERSION"

if blm_has_command bash; then
  printf 'Bash is available through PATH.\n'
fi

if blm_is_tty; then
  printf 'stdout is connected to a TTY.\n'
else
  printf 'stdout is not connected to a TTY.\n'
fi

if blm_color_enabled; then
  printf 'ANSI color is enabled for this context.\n'
else
  printf 'ANSI color is disabled for this context.\n'
fi

blm_info "foundation information"
blm_success "foundation success"
blm_warn "foundation warning demonstration"
blm_error "foundation error demonstration"

printf 'Foundation example completed.\n'
