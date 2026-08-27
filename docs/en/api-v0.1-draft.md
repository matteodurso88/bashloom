# Draft v0.1 API Specification

> Status: **Draft**. These public APIs are implemented but are not yet covered by a stable compatibility guarantee.

## Foundation and terminal capability

- `blm_has_command <name>`
- `blm_is_tty`
- `blm_color_enabled`
- `blm_info <message...>`
- `blm_success <message...>`
- `blm_warn <message...>`
- `blm_error <message...>`

## M1 — Command runtime

- `blm_run [--dry-run] [--] <command> [args...]`
- `blm_step <label> <command> [args...]`

`blm_run` preserves the wrapped command status and supports both local `--dry-run` and global `BLM_DRY_RUN=1`.

## M2 — Reliability

- `blm_retry [--attempts N] [--delay S] [--backoff N] [--] <command> [args...]`
- `blm_wait_for [--timeout S] [--interval S] [--] <command> [args...]`
- `blm_timeout [--timeout S] [--grace S] [--] <command> [args...]`
- `blm_cleanup_add <command> [args...]`
- `blm_cleanup_run`
- `blm_cleanup_clear`
- `blm_cleanup_enable_traps`
- `blm_cleanup_disable_traps`
- `blm_rollback_add <command> [args...]`
- `blm_rollback_run`
- `blm_rollback_clear`
- `blm_transaction_begin`
- `blm_transaction_commit`
- `blm_transaction_rollback`

Timeout-style operations use status `124` for an expired deadline. Cleanup and rollback stacks use LIFO order.

## M3 — System safety

- `blm_require_command <name>`
- `blm_require_file <path>`
- `blm_require_dir <path>`
- `blm_require_env <name>`
- `blm_require_root`
- `blm_require_readable <path>`
- `blm_require_writable <path>`
- `blm_require_executable <path>`
- `blm_temp_file [directory]`
- `blm_temp_dir [directory]`
- `blm_ensure_dir [--mode MODE] <path>`
- `blm_ensure_symlink <target> <link>`
- `blm_atomic_write <path> <producer-command> [args...]`
- `blm_path_is_absolute <path>`
- `blm_path_dirname <path>`
- `blm_path_basename <path>`
- `blm_path_join <part>...`

## M4 — Runtime state

- `blm_output_mode`
- `blm_kv <key> <value>`
- `blm_log <debug|info|warn|error> <message...>`
- `blm_env_get <NAME> [fallback]`
- `blm_env_bool <NAME> [fallback]`
- `blm_config_validate <file>`
- `blm_config_get <file> <key> [fallback]`
- `blm_config_has <file> <key>`
- `blm_state_get <file> <key> [fallback]`
- `blm_state_set <file> <key> <value>`
- `blm_state_delete <file> <key>`

`BLM_OUTPUT_MODE` accepts `human`, `plain`, or `json`. `BLM_LOG_LEVEL` controls log filtering and `BLM_LOG_FILE` optionally persists accepted records.

Configuration and state use literal `key=value` data. They are never loaded through `source` or `eval`.

## M5 — Consumption

When `src/bashloom-loader.sh` is sourced directly, the following public loader API is available:

- `blm_load <module> [module...]`

Supported module groups are:

- `core`
- `status`
- `logging`
- `requirements`
- `runtime`
- `reliability`
- `system`
- `state`
- `all`

Module loading is dependency-aware and idempotent. Unknown module names return status `2`.

The normal `src/bashloom.sh` entrypoint remains the complete-runtime interface and internally loads `all`.

Installation, vendoring and release commands under `tools/` are project tooling rather than sourced public runtime APIs.

## Detailed contracts

See:

- `docs/en/runtime-reliability.md`
- `docs/en/system-safety.md`
- `docs/en/runtime-state.md`
- `docs/en/consumption.md`
- `docs/en/compatibility.md`
- `examples/README.md`

## Exit semantics

Unless a function explicitly transforms an outcome, Bashloom wrappers preserve or faithfully report the status of the operation they wrap. Rendering must not accidentally replace command failures.

Status `2` is generally used for invalid Bashloom arguments or configuration values. Timeout operations use `124` where documented.

## Side effects

Sourcing `src/bashloom.sh` or `src/bashloom-loader.sh` must not implicitly enable strict mode, replace caller traps, modify `IFS`, emit user-visible output, read configuration/state, create log files, or execute caller-provided text.

Feature-specific external utilities may be required only when the corresponding function is invoked; sourcing the runtime or loader itself remains dependency-free apart from Bash.
