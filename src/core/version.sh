#!/usr/bin/env bash

# Bashloom version metadata.
#
# This file intentionally performs no shell-option changes and no output when
# sourced. Public consumers may read BLM_VERSION for diagnostics or feature
# reporting, but must not parse it as a compatibility contract before v1.0.

# Public metadata is consumed by downstream scripts after sourcing Bashloom.
# shellcheck disable=SC2034
BLM_VERSION="0.1.0-rc1"
