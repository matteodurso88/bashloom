#!/usr/bin/env bash

# Human, plain and machine-readable output primitives.

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

blm_output_mode() {
  _blm_output_mode
}

_blm_json_escape() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

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
