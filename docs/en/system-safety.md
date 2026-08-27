# System safety API

This document describes Bashloom M3 filesystem and permission primitives.

> Status: pre-v0.1. Public APIs may still change before the first tagged usable release.

## Requirements

### `blm_require_root`
Returns success only when `EUID == 0`.

### `blm_require_readable <path>`
Requires the current process to have read access.

### `blm_require_writable <path>`
Requires the current process to have write access.

### `blm_require_executable <path>`
Requires the current process to have execute/search access.

These helpers report runtime access according to Bash file tests. They do not attempt privilege escalation.

## Temporary resources

### `blm_temp_file [directory]`
Creates a unique temporary file using `mktemp` with an effective `umask 077`. The default base directory is `${TMPDIR:-/tmp}`.

### `blm_temp_dir [directory]`
Creates a unique temporary directory using `mktemp -d` with an effective `umask 077`.

`mktemp` is required only when these functions are invoked; sourcing Bashloom does not require it.

## Idempotent filesystem helpers

### `blm_ensure_dir [--mode MODE] <path>`
Creates a directory tree with `mkdir -p`. Repeating the call is safe. When `--mode` is provided, `chmod` is applied after creation.

### `blm_ensure_symlink <target> <link>`
Creates a symbolic link when absent. If an existing symlink already points to the requested target, the call succeeds without changes. A conflicting symlink or non-symlink path is rejected instead of being overwritten.

## Atomic writes

### `blm_atomic_write <path> <producer-command> [args...]`
Runs the producer command with stdout redirected to a secure temporary file in the destination directory. The destination is replaced with `mv` only after the producer succeeds.

Properties:
- the destination remains untouched when the producer fails;
- the temporary file is created in the same directory, allowing same-filesystem atomic rename semantics;
- when replacing an existing file on GNU/Linux, its mode is copied with `chmod --reference`;
- no command string is evaluated.

This initial implementation is Linux-first. The `--reference` mode-preservation behavior will be revisited during macOS compatibility hardening.

## Path helpers

### `blm_path_is_absolute <path>`
Returns success for paths beginning with `/`.

### `blm_path_dirname <path>`
Returns the lexical directory component using pure Bash.

### `blm_path_basename <path>`
Returns the lexical final component using pure Bash.

### `blm_path_join <part>...`
Joins path components without invoking external utilities.

These helpers are lexical only: they do not resolve symlinks, `..`, or filesystem canonicalization.

## Source-safety improvement

The Bashloom entrypoint now resolves its own directory without calling external `dirname`. Sourcing the runtime therefore remains possible even with an empty/unusable `PATH`, provided Bash itself can access the source files.
