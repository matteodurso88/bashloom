#!/usr/bin/env bash

# Bashloom full runtime entrypoint.
#
# This file is designed to be sourced. It intentionally does not enable strict
# mode, mutate IFS, install traps or emit output. The caller retains control of
# its shell execution model.
#
# Consumers that need only a subset of Bashloom may source bashloom-loader.sh
# directly and call blm_load with one or more module groups.

_BLM_ENTRY=${BASH_SOURCE[0]}
_BLM_ENTRY_DIR=${_BLM_ENTRY%/*}
[[ $_BLM_ENTRY_DIR == "$_BLM_ENTRY" ]] && _BLM_ENTRY_DIR=.
_BLM_ROOT="$(cd -- "$_BLM_ENTRY_DIR" && pwd)"
unset _BLM_ENTRY _BLM_ENTRY_DIR

# shellcheck source=src/bashloom-loader.sh
source "$_BLM_ROOT/bashloom-loader.sh"
blm_load all
