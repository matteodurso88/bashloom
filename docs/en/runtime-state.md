# Runtime state API

This document describes Bashloom M4 output, logging, environment, configuration and state primitives.

> Status: pre-v0.1. Public APIs may still change before the first tagged usable release.

## Output modes

Set `BLM_OUTPUT_MODE` to one of:

- `human` — default terminal-oriented rendering, including color when supported;
- `plain` — deterministic text without ANSI color;
- `json` — one JSON object per emitted status/key-value record.

### `blm_output_mode`
Prints the effective output mode. Invalid values return status `2`.

### `blm_kv <key> <value>`
Emits one key/value record using the active output mode.

Existing status helpers (`blm_info`, `blm_success`, `blm_warn`, `blm_error`) now honor `BLM_OUTPUT_MODE`. Stream semantics remain unchanged: info/success use stdout, warn/error use stderr.

## Logging

### `blm_log <debug|info|warn|error> <message...>`
Emits a filtered log record. `BLM_LOG_LEVEL` defaults to `info` and accepts `debug`, `info`, `warn`, or `error`.

When `BLM_LOG_FILE` is non-empty, accepted records are also appended to that file using a stable timestamped plain-text format. The console side still follows `BLM_OUTPUT_MODE`.

No log file is opened and no output is produced merely by sourcing Bashloom.

## Environment helpers

### `blm_env_get <NAME> [fallback]`
Prints the exact value of a valid environment variable. If it is unset, the optional fallback is printed. Without a fallback, an unset variable returns status `1`.

### `blm_env_bool <NAME> [fallback]`
Interprets common boolean values:

- true: `1`, `true`, `yes`, `on`;
- false: `0`, `false`, `no`, `off`.

Invalid boolean text returns status `2`. The helper does not modify the environment.

## Safe configuration

Bashloom configuration files use a deliberately small data format:

```text
# comment
APP_NAME=Bashloom
MODE=production
```

Rules:

- blank lines and lines beginning with `#` are ignored;
- all other lines must be `key=value`;
- keys use letters, digits, `_`, `.`, and `-`, and must start with a letter or `_`;
- values are literal text;
- quotes, `$()`, backticks, variable references and shell syntax are never evaluated;
- duplicate requested keys are rejected.

### `blm_config_validate <file>`
Validates the file as Bashloom key/value data.

### `blm_config_get <file> <key> [fallback]`
Reads a literal value. Missing keys return `1` unless a fallback is supplied.

### `blm_config_has <file> <key>`
Returns success when the key exists and is unambiguous.

Bashloom never implements config loading by `source` or `eval`.

## State files

State files use the same key/value data model as configuration files.

### `blm_state_get <file> <key> [fallback]`
Reads state. A missing state file behaves like a missing key.

### `blm_state_set <file> <key> <value>`
Creates or updates one key through `blm_atomic_write`. Values containing newlines are rejected so the file remains structurally unambiguous.

### `blm_state_delete <file> <key>`
Removes one key atomically. Deleting from a missing file succeeds as a no-op.

State writes preserve unrelated valid lines and comments. Existing malformed state files are rejected instead of being silently rewritten.

## Source safety

M4 keeps the existing source-safety contract. Sourcing Bashloom does not:

- select an output mode globally;
- create or open a log file;
- read configuration;
- create state;
- mutate environment variables;
- execute caller-provided text.
