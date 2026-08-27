# Idempotency and change tracking

Bashloom provides explicit change tracking for convergence-style automation. The goal is to let a script answer two separate questions:

1. did the most recent tracked operation modify the system?
2. did any tracked operation modify the system during this run?

## Change state

Two public variables expose this state:

- `BLM_LAST_CHANGED` — `1` when the most recent tracked operation changed something, otherwise `0`;
- `BLM_CHANGED` — aggregate flag that remains `1` after any tracked change until explicitly reset.

Use:

```bash
blm_change_reset

blm_ensure_dir --mode 700 /var/lib/myapp
if blm_last_changed; then
  printf 'directory changed\n'
fi

blm_ensure_line /etc/myapp.conf 'enabled=true'

if blm_changed; then
  printf 'the run changed the system\n'
fi
```

`blm_change_reset` resets both flags to `0`.

`blm_last_changed` and `blm_changed` return shell success when the corresponding flag is set.

## Idempotent filesystem primitives

### `blm_ensure_dir [--mode MODE] <path>`

Creates the directory tree when missing. When `--mode` is supplied, the existing mode is checked and corrected only when necessary.

Change semantics:

- missing directory created: changed;
- existing directory already correct: no change;
- existing directory mode corrected: changed.

Linux mode inspection currently uses `stat -c`.

### `blm_ensure_symlink <target> <link>`

Creates the symlink when missing and returns no change when the exact target is already present. A conflicting symlink or a non-symlink path is rejected rather than replaced silently.

### `blm_ensure_mode <mode> <path>`

Ensures a filesystem object has the requested permission mode. `chmod` is executed only when the current mode differs.

### `blm_ensure_line <path> <line>`

Ensures an exact literal line is present in a regular file.

- missing file: created with the requested line;
- existing file without the exact line: line appended;
- exact line already present: no change;
- parent directory must already exist;
- shell expressions inside the line are treated as literal data.

This helper intentionally performs exact whole-line matching. It is not a regular-expression editor or a key/value replacement engine.

## Aggregate convergence pattern

A common pattern is:

```bash
blm_change_reset

blm_ensure_dir --mode 700 "$app_dir"
blm_ensure_line "$config" 'enabled=true'
blm_ensure_mode 600 "$config"
blm_ensure_symlink "$config" "$current_link"

if blm_changed; then
  blm_info "configuration converged with changes"
else
  blm_info "system already converged"
fi
```

The same block can be executed repeatedly. Once the desired state has been reached, a subsequent run should become a no-op.

## Scope and portability

This milestone is Linux-first. Cross-distribution, macOS and WSL compatibility matrices are intentionally deferred until those environments can be validated directly.

The current implementation also hardens existing filesystem operations by checking `readlink` and `rm` explicitly when they are required instead of assuming they are available.
