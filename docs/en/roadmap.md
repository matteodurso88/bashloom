# Roadmap

Bashloom is currently in the foundation / early v0.1 implementation phase. The roadmap is intentionally capability-driven rather than date-driven.

## pre-v0.1 — Foundation

- [x] project identity and ownership model
- [x] EN/IT documentation policy
- [x] architecture baseline
- [x] source-safe runtime entrypoint
- [x] version metadata
- [x] basic capability detection
- [x] basic status output
- [x] basic requirement checks
- [x] Bats smoke tests
- [x] ShellCheck/shfmt/Bats CI
- [x] contributor issue and pull-request templates
- [x] draft API specification for v0.1 primitives
- [ ] compatibility test matrix

## v0.1 — Reliable Shell Foundation

### M1 — Command Runtime

- [x] `blm_run`
- [x] exact exit-status preservation
- [x] caller `set -e` compatibility
- [x] local `--dry-run`
- [x] global `BLM_DRY_RUN=1`
- [x] `blm_step`
- [x] no `eval` / argv-safe execution

### M2 — Reliability

- [x] `blm_retry`
- [x] retry delay and integer backoff
- [x] `blm_wait_for`
- [x] timeout status `124`
- [x] `blm_timeout`
- [x] LIFO cleanup stack
- [x] explicit cleanup trap installation
- [x] refusal to overwrite caller traps
- [x] LIFO rollback stack
- [x] explicit begin/commit/rollback transactions
- [x] Bats contract coverage for M1/M2
- [x] EN/IT runtime/reliability documentation

### M3 — System Safety

- [x] require root
- [x] readable/writable/executable permission checks
- [x] safe temporary directory/file helpers
- [x] ensure directory
- [x] ensure symlink
- [x] atomic file write
- [x] pure-Bash lexical path helpers
- [x] dependency-free entrypoint path resolution
- [x] Bats contract coverage for M3
- [x] EN/IT system-safety documentation

### M4 — Runtime State

Next implementation block:

- [ ] logging foundations
- [ ] environment helpers
- [ ] safe configuration helpers
- [ ] state files
- [ ] human/plain/machine-readable output model

### M5 — Consumption

- [ ] installation model
- [ ] vendoring guidance
- [ ] selective module loading
- [ ] compatibility documentation
- [ ] versioning/release workflow

### M6 — Production Validation

- [ ] integrate Bashloom primitives into at least one real deployment workflow
- [ ] validate against a desktop/installer workflow
- [ ] validate against a system/provisioning workflow
- [ ] revise unstable APIs from field feedback
- [ ] tag the first usable `v0.1.0`

### Remaining v0.1 UI/Core work

- [ ] richer terminal capability model
- [ ] output mode model
- [ ] color and Unicode policy hardening
- [ ] runtime/version diagnostics
- [ ] title/section helpers
- [ ] key/value output
- [ ] explicit error/exit helpers

### Quality

- [x] ShellCheck clean for implemented M1/M2 baseline
- [x] shfmt clean for implemented M1/M2 baseline
- [x] Bats tests for implemented public APIs
- [ ] Bash version matrix
- [ ] cross-distribution matrix
- [ ] documentation parity checks where practical

## v0.2 — Terminal UX

Candidate scope:

- panels
- tables
- tree rendering
- spinner
- progress
- timers
- confirm/input/password/select
- optional enhanced backends such as Gum/fzf

## v0.3 — System & Integrations

Candidate scope:

- Git adapter
- Docker adapter
- systemd adapter
- Debian/APT helpers
- XDG helpers
- network checks

## Later exploration

- human/plain/JSON output refinements
- vendorable module bundler
- generated API reference
- shell completion for a future Bashloom CLI

No item beyond v0.1 is considered committed until specified through documentation and, where appropriate, an ADR.
