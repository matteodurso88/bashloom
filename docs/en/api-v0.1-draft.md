# Draft v0.1 API Specification

> Status: **Draft**. The functions below are not yet covered by a stable compatibility guarantee.

## Current foundation API

### `blm_has_command <name>`

Returns success when `<name>` resolves through `PATH`.

### `blm_is_tty`

Returns success when standard output is connected to a terminal.

### `blm_color_enabled`

Returns success when Bashloom considers ANSI color appropriate. Current conditions disable color when `NO_COLOR` is non-empty, `TERM=dumb`, or stdout is not a TTY.

### `blm_info <message...>`

Prints an informational status line to stdout.

### `blm_success <message...>`

Prints a success status line to stdout.

### `blm_warn <message...>`

Prints a warning status line to stderr.

### `blm_error <message...>`

Prints an error status line to stderr.

### `blm_require_command <name>`

Returns failure and writes a diagnostic to stderr when a command cannot be resolved through `PATH`.

### `blm_require_file <path>`

Returns failure when `<path>` is not a regular file.

### `blm_require_dir <path>`

Returns failure when `<path>` is not a directory.

### `blm_require_env <name>`

Returns failure when the named environment variable is unset or empty.

## v0.1 candidates not yet implemented

The following are planned capabilities, not current API contracts:

- `blm_run`
- `blm_step`
- `blm_retry`
- `blm_wait_until`
- cleanup stack primitives
- title/section output
- key/value output
- safe temporary-resource helpers
- atomic write helpers
- permission checks

Each candidate requires behavior specification, tests and EN/IT documentation before being considered part of the v0.1 public API.

## Exit semantics

Unless a function's purpose is explicitly to transform an outcome, Bashloom wrappers must preserve or faithfully report the exit status of the operation they wrap. Rendering output after a command must not accidentally replace that command's status.

## Side effects

Sourcing `src/bashloom.sh` must not implicitly enable shell strict mode, replace traps, modify `IFS`, execute external commands other than the shell built-ins required to resolve the Bashloom source path, or emit user-visible output.
