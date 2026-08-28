# v0.1 RC semantic hardening

This document records behavior intentionally stabilized before the common multi-consumer v0.1 release-candidate validation campaign.

## Timeout and descendants

`blm_timeout` preserves the existing command-status contract and status `124` for enforced deadlines.

When the wrapped command resolves to an external executable and GNU coreutils `timeout` is available, Bashloom delegates the deadline to that backend. GNU timeout provides mature process-group signaling, so TERM/KILL escalation reaches descendants created by the command as well as the direct command process.

Shell functions and builtins retain Bashloom's direct-child compatibility path because re-executing caller shell state through an external wrapper would change semantics. Hosts without GNU timeout also use the direct Bash backend. All dependencies remain call-time only; sourcing Bashloom does not require GNU timeout.

`--timeout 0` keeps Bashloom's historical immediate-deadline behavior even though GNU timeout interprets duration zero as disabled. `--grace 0` means immediate escalation and is mapped to a minimal positive GNU kill-after interval because GNU `-k 0` disables escalation.

## Numeric filesystem modes

`blm_ensure_dir --mode` and `blm_ensure_mode` accept numeric octal permission modes only. Invalid/non-octal mode input returns `2` before filesystem mutation.

A conventional leading zero is normalized only for comparison with GNU `stat -c %a`; the original validated mode is passed to `chmod`.

## Single-line convergence

`blm_ensure_line` is explicitly a one-logical-line API. LF and CR in the requested line are rejected with status `2` before the destination is changed.

## Atomic write semantics

`blm_atomic_write` provides **same-filesystem atomic replacement**, not power-loss durability. It does not promise `fsync` of file or directory metadata.

When replacing an existing destination, mode preservation currently requires GNU `chmod --reference`. Failure to preserve the mode aborts replacement and leaves the previous destination intact.

## JSON strings

Bashloom's core JSON escaping now covers every C0 control character representable in a Bash variable. Bash variables cannot contain NUL bytes. Printable Unicode is preserved.

This remains a focused string-escaping helper for Bashloom's line-oriented JSON records, not a general binary JSON serializer.

## Lock policy

Directory locks deliberately do **not** auto-recover stale paths in v0.1. Safe staleness decisions depend on application-specific ownership, host and liveness policy. An existing lock directory therefore remains a failed non-blocking acquisition.

## Config comments

The literal config format intentionally recognizes comments only when `#` is the first byte. Leading whitespace is data and will fail key validation when it makes the key invalid. Bashloom does not trim or normalize config input.

## Log-file parent policy

`BLM_LOG_FILE` is append-only and never causes Bashloom to create its parent directory implicitly. A missing/unwritable parent makes persistence fail. Callers that want convergence should create/validate the directory explicitly before enabling file logging.

These policies are part of the v0.1 RC freeze candidate and should only change after field evidence demonstrates a defect or unacceptable usability problem.
