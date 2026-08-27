# Output and Error Model

Bashloom keeps presentation, diagnostics and error signaling explicit so sourced scripts remain safe to compose inside applications, deployment scripts and CI jobs.

## Presentation helpers

```bash
blm_title <message...>
blm_section <message...>
```

Both helpers honor `BLM_OUTPUT_MODE`:

- `human` renders lightweight terminal-oriented headings;
- `plain` emits deterministic `type: message` records;
- `json` emits one JSON object per record.

They do not inspect terminal width or emit Unicode-only decoration.

## Runtime diagnostics

```bash
blm_diagnostics
```

The diagnostic contract currently reports:

- `bashloom_version`
- `bash_version`
- `output_mode`
- `tty`
- `color`
- `ci`

Diagnostics use `blm_kv`, so the output remains consistent with human/plain/JSON mode. The function is informational and has no runtime side effects.

## Explicit failure helpers

```bash
blm_fail <status> <message...>
blm_usage_error <message...>
```

`blm_fail` renders an error and returns the requested status. Valid statuses are integers from 1 through 255. Invalid status arguments return `2`.

`blm_usage_error` renders an error and returns `2`, the Bashloom convention for invalid public API arguments or usage.

Neither helper calls `exit`. This is deliberate: Bashloom is commonly sourced into another script, so the caller retains control over rollback, cleanup, recovery or process termination.

Example:

```bash
if blm_fail 17 "deployment failed"; then
  :
else
  status=$?
  rollback_deployment
  exit "$status"
fi
```

## Machine-readable behavior

In JSON mode, presentation and diagnostic records are newline-delimited JSON objects. Bashloom does not wrap an entire command invocation in one large JSON document; this keeps streaming output usable in CI and shell pipelines.

Status helpers continue to emit errors and warnings on stderr and informational/success output on stdout according to their existing contracts.

## Source safety

Sourcing Bashloom still performs no presentation, diagnostics or error output automatically. All M6B behavior is opt-in through explicit function calls.
