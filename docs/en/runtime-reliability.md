# Runtime and reliability API

This document describes the first operational Bashloom primitives introduced for the v0.1 runtime.

> Status: pre-v0.1. Public APIs may still change before the first tagged usable release.

## Command execution

### `blm_run [--dry-run] [--] <command> [args...]`

Executes a command from its original Bash argument vector. Bashloom does not build or evaluate a command string.

Properties:

- preserves the wrapped command exit status;
- remains usable when the caller enables `set -e`;
- supports local `--dry-run` and global `BLM_DRY_RUN=1`;
- dry-run prints a shell-escaped representation and returns `0` without executing the command;
- unknown Bashloom options return `2`.

Use `--` before commands that may begin with `-`.

### `blm_step <label> <command> [args...]`

Renders a start/result status around `blm_run` and returns the wrapped command exit status unchanged.

## Retry and polling

### `blm_retry [--attempts N] [--delay S] [--backoff N] [--] <command> [args...]`

Defaults:

- attempts: `3`;
- delay: `1` second;
- backoff multiplier: `1`.

The command is retried until it succeeds or the attempt budget is exhausted. If all attempts fail, the final command status is returned.

Positive delays use the standard `sleep` utility. Bashloom itself remains sourceable without `sleep`; only features that actually wait require it.

### `blm_wait_for [--timeout S] [--interval S] [--] <command> [args...]`

Polls until the command returns `0`.

Defaults:

- timeout: `30` seconds;
- interval: `1` second.

Returns:

- `0` when the condition succeeds;
- `124` when the deadline expires;
- `2` for invalid Bashloom arguments;
- `127` if a required wait utility cannot be executed.

## Command timeout

### `blm_timeout [--timeout S] [--grace S] [--] <command> [args...]`

Runs the command in an isolated child process. On deadline, Bashloom sends `TERM`, waits for the grace period, then sends `KILL` if the process is still alive.

Defaults:

- timeout: `30` seconds;
- grace: `1` second.

Returns `124` on timeout. Otherwise it preserves the child command status.

### Isolation contract

Because a timed command must be independently terminable, it runs in a subshell. A shell function passed to `blm_timeout` therefore **cannot persist variable or working-directory changes into the caller**. Use `blm_timeout` for externally observable work, probes and commands, not for functions whose purpose is to mutate caller shell state.

## Cleanup stack

### `blm_cleanup_add <command> [args...]`

Registers a cleanup action. Commands and arguments are stored as Bash arrays; no `eval` or command-string reconstruction is used.

### `blm_cleanup_run`

Runs registered cleanup actions in **LIFO** order. All actions are attempted even if one fails. The first non-zero cleanup status is returned after the stack has been processed.

### `blm_cleanup_clear`

Discards registered cleanup actions without running them.

### `blm_cleanup_enable_traps`

Explicitly installs Bashloom handlers for `EXIT`, `INT` and `TERM`.

This function is intentionally conservative: if any of those traps already exists, Bashloom refuses installation instead of overwriting caller behavior.

Sourcing Bashloom never installs traps automatically.

### `blm_cleanup_disable_traps`

Removes traps previously installed by Bashloom.

## Rollback and transactions

### `blm_rollback_add <command> [args...]`

Registers an explicit rollback action.

### `blm_rollback_run`

Runs rollback actions in **LIFO** order, attempts every action and returns the first non-zero rollback status.

### `blm_transaction_begin`

Starts one Bashloom transaction and clears stale rollback state. Nested transactions are not supported in the v0.1 runtime.

### `blm_transaction_commit`

Commits the active transaction by discarding its rollback stack.

### `blm_transaction_rollback`

Executes the active rollback stack and ends the transaction.

## `set -e` behavior

The runtime captures failures through conditional command contexts instead of temporarily disabling `errexit`. Bashloom therefore does not mutate the caller's shell options and can inspect failed command statuses before returning them.

The caller still controls final behavior. For example:

```bash
set -e
source ./src/bashloom.sh

blm_run deploy
```

If `deploy` returns non-zero, `blm_run` returns the same status and the caller's `set -e` policy may then terminate the script normally.

To handle the failure explicitly:

```bash
if blm_run deploy; then
  blm_success "Deployment complete"
else
  status=$?
  blm_error "Deployment failed with exit $status"
fi
```
