# Compatibility

Bashloom is Linux-first and targets Bash **4.3 or newer**.

## Supported environments

| Environment | Status | Notes |
| --- | --- | --- |
| Linux | primary | development and CI baseline |
| WSL | supported | expected to behave like the corresponding Linux userspace |
| macOS | best effort | Bash version and BSD/GNU utility differences must be considered |
| POSIX `sh` / `dash` / `ash` | unsupported | Bash-specific features are intentional |

## Shell requirements

Bashloom uses Bash features such as arrays, namerefs and `[[ ... ]]`. Consumers must invoke Bash explicitly or run under a Bash shebang.

The runtime entrypoints are source-safe: sourcing Bashloom does not intentionally enable strict mode, replace caller traps, alter `IFS`, invoke `sudo`, or emit output.

## Runtime dependency model

Bash itself is the only mandatory dependency for sourcing the core runtime and loader. Individual features may require standard operating-system utilities when invoked.

Current feature-specific utilities include:

- temporary resources: `mktemp`;
- directory helpers: `mkdir`, optionally `chmod`;
- symlink helpers: `ln`, `readlink`;
- atomic replacement: `mv`, `chmod`, cleanup through `rm`;
- retry/wait/timeout: `sleep`;
- installer/vendoring tooling: `mkdir`, `cp`, `mv`, `rm`.

Bashloom checks feature dependencies at or near the point of use where practical. Sourcing the complete runtime must not require those commands to execute successfully.

## GNU/Linux-specific behavior

`blm_atomic_write` currently preserves the mode of an existing destination through GNU `chmod --reference`. This is part of the Linux-first implementation and is not yet portable to the BSD `chmod` shipped by macOS.

The current atomic-write contract covers atomic replacement on the same filesystem. It does not promise power-loss durability through explicit file and directory `fsync` operations.

## Terminal behavior

Status output degrades when color is unavailable. Bashloom considers `NO_COLOR`, `TERM=dumb` and non-TTY output. Machine-readable output must not depend on terminal styling or emoji support.

## CI compatibility status

Before v0.1.0 the project still needs a formal Bash-version and cross-distribution CI matrix. Until that matrix exists, the authoritative continuously tested baseline is the Ubuntu GitHub Actions runner used by the repository CI.
