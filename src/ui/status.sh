#!/usr/bin/env bash

# Status helpers render through the configured Bashloom output mode.

blm_info() {
  _blm_emit_status stdout info INFO '\033[36m' "$@"
}

blm_success() {
  _blm_emit_status stdout success OK '\033[32m' "$@"
}

blm_warn() {
  _blm_emit_status stderr warn WARN '\033[33m' "$@"
}

blm_error() {
  _blm_emit_status stderr error ERROR '\033[31m' "$@"
}
