#!/usr/bin/env bash

# Bashloom runtime entrypoint.
#
# This file is designed to be sourced. It intentionally does not enable strict
# mode, mutate IFS, install traps or emit output. The caller retains control of
# its shell execution model.

_BLM_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=src/core/version.sh
source "$_BLM_ROOT/core/version.sh"
# shellcheck source=src/core/capabilities.sh
source "$_BLM_ROOT/core/capabilities.sh"
# shellcheck source=src/core/validate.sh
source "$_BLM_ROOT/core/validate.sh"
# shellcheck source=src/ui/status.sh
source "$_BLM_ROOT/ui/status.sh"
# shellcheck source=src/ops/require.sh
source "$_BLM_ROOT/ops/require.sh"
# shellcheck source=src/ops/run.sh
source "$_BLM_ROOT/ops/run.sh"
# shellcheck source=src/ops/step.sh
source "$_BLM_ROOT/ops/step.sh"
# shellcheck source=src/ops/retry.sh
source "$_BLM_ROOT/ops/retry.sh"
# shellcheck source=src/ops/wait.sh
source "$_BLM_ROOT/ops/wait.sh"
# shellcheck source=src/ops/timeout.sh
source "$_BLM_ROOT/ops/timeout.sh"
# shellcheck source=src/ops/cleanup.sh
source "$_BLM_ROOT/ops/cleanup.sh"
# shellcheck source=src/ops/rollback.sh
source "$_BLM_ROOT/ops/rollback.sh"
