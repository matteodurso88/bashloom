#!/usr/bin/env bash

# Human, plain and machine-readable output primitives.
#
# Output mode is resolved at call time rather than cached while sourcing. This
# allows scripts to switch presentation mode deliberately between operations
# and preserves Bashloom's no-output/no-runtime-side-effects sourcing contract.

# Internal helper: validate and print the effective output mode.
# Direct printf is intentional here because this function is the bootstrap path
# used by all higher-level renderers; it cannot depend on blm_error safely.
_blm_output_mode() {
  local mode=${BLM_OUTPUT_MODE:-human}
  case $mode in
    human | plain | json)
      printf '%s\n' "$mode"
      ;;
    *)
      printf '[ERROR] Invalid BLM_OUTPUT_MODE: %s\n' "$mode" >&2
      return 2
      ;;
  esac
}

# Public API: blm_output_mode
# Purpose: Print the validated effective Bashloom output mode.
# Usage: blm_output_mode
# Returns: 0 for human/plain/json; 2 for an invalid BLM_OUTPUT_MODE value.
# Output: Effective mode to stdout, bootstrap validation error to stderr.
# Side effects: None.
blm_output_mode() {
  _blm_output_mode
}

# Internal helper: escape one string for Bashloom's single-line JSON records.
# Bash parameter substitutions avoid a jq/Python dependency in core output.
# The helper escapes the JSON-sensitive characters Bashloom records may emit;
# callers must not use it as a general-purpose serializer for arbitrary binary
# data or as a replacement for a full JSON implementation.
_blm_json_escape() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

# Internal renderer: emit one status/event record to the selected stream.
# Arguments are stream, semantic level, human label, ANSI color, then message
# words. JSON deliberately omits presentation-only label/color fields.
_blm_emit_status() {
  (($# >= 5)) || return 2
  local stream=$1
  local level=$2
  local label=$3
  local color=$4
  shift 4
  local message=$*
  local fd=1
  [[ $stream == stderr ]] && fd=2

  local mode
  mode=$(_blm_output_mode) || return $?

  case $mode in
    human)
      # Color is a capability/policy decision, never forced merely because
      # human mode is active.
      if blm_color_enabled; then
        printf '%b[%s]\033[0m %s\n' "$color" "$label" "$message" >&"$fd"
      else
        printf '[%s] %s\n' "$label" "$message" >&"$fd"
      fi
      ;;
    plain)
      printf '[%s] %s\n' "$label" "$message" >&"$fd"
      ;;
    json)
      printf '{"level":"%s","message":"%s"}\n' \
        "$(_blm_json_escape "$level")" \
        "$(_blm_json_escape "$message")" >&"$fd"
      ;;
  esac
}

# Public API: blm_kv
# Purpose: Emit one key/value fact using the configured output contract.
# Usage: blm_kv <key> <value>
# Returns:
#   0  Record rendered successfully.
#   2  Invalid arguments or invalid output-mode configuration.
# Output:
#   human/plain: `key: value`
#   json: one JSON object with `key` and `value` string fields.
# Side effects: Writes one record to stdout only.
# Notes: Values are intentionally strings in JSON to keep this primitive simple
# and deterministic; typed JSON belongs to a richer future serialization API.
blm_kv() {
  (($# == 2)) || return 2
  local key=$1
  local value=$2
  local mode
  mode=$(_blm_output_mode) || return $?

  case $mode in
    human | plain)
      printf '%s: %s\n' "$key" "$value"
      ;;
    json)
      printf '{"key":"%s","value":"%s"}\n' \
        "$(_blm_json_escape "$key")" \
        "$(_blm_json_escape "$value")"
      ;;
  esac
}
