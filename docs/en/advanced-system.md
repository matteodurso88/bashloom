# Advanced system primitives

Bashloom M6C adds Linux-first helpers for safer filesystem changes, locking, ownership convergence, checksums and XDG paths.

## Safe filesystem operations

```bash
blm_backup <source> <backup>
blm_safe_copy <source> <destination>
blm_safe_move <source> <destination>
```

These helpers refuse to overwrite an existing destination. They preserve the source metadata supported by `cp -a` and participate in Bashloom change tracking after a successful mutation.

`blm_backup` is intentionally explicit: the caller chooses the backup path. Bashloom does not generate timestamps or rotate backups implicitly.

## SHA-256

```bash
blm_checksum_sha256 <file>
```

The helper prints only the hexadecimal digest. `sha256sum` is required only when this function is invoked.

## Directory locks

```bash
blm_lock_acquire <lock-path>
blm_lock_release <lock-path>
blm_with_lock <lock-path> <command> [args...]
```

Locks are represented by directories and acquired through atomic `mkdir`. This keeps the primitive dependency-light and makes lock state visible on the filesystem.

Acquisition is non-blocking: an already existing lock returns status `1`. `blm_with_lock` preserves the wrapped command status and then attempts to release the lock.

These primitives are not a lease system and do not automatically recover stale locks after crashes or machine failure. Stale-lock policy remains the caller's responsibility.

## Ownership convergence

```bash
blm_ensure_owner <user:group> <path>
```

The helper compares the current owner and group using GNU/Linux `stat -c`. It calls `chown` only when the requested ownership differs and participates in change tracking.

Privilege escalation is never implicit. If changing ownership requires elevated privileges, the caller must already be running with sufficient permissions.

## XDG paths

```bash
blm_xdg_config_home
blm_xdg_data_home
blm_xdg_cache_home
blm_xdg_state_home
blm_xdg_runtime_dir
```

The first four helpers honor the corresponding XDG environment variable and otherwise use the standard HOME-based defaults:

- config: `$HOME/.config`
- data: `$HOME/.local/share`
- cache: `$HOME/.cache`
- state: `$HOME/.local/state`

`blm_xdg_runtime_dir` requires `XDG_RUNTIME_DIR` explicitly. Bashloom does not invent a fallback because that would weaken the ownership/lifetime guarantees expected for runtime directories.

## Scope

This milestone is Linux-first. Cross-distribution, macOS and WSL validation remain deferred until those environments can be tested directly.
