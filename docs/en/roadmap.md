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

- [x] retry/wait/timeout primitives
- [x] timeout status `124`
- [x] LIFO cleanup with explicit trap installation
- [x] LIFO rollback and explicit transactions
- [x] Bats coverage and EN/IT documentation

### M3 — System Safety

- [x] root/permission requirements
- [x] secure temporary resources
- [x] directory/symlink ensures
- [x] atomic file writes
- [x] pure-Bash lexical path helpers
- [x] Bats coverage and EN/IT documentation

### M4 — Runtime State

- [x] logging and environment helpers
- [x] safe literal configuration
- [x] atomic state files
- [x] human/plain/JSON output model
- [x] Bats coverage, maintained example and EN/IT documentation

### M5 — Consumption

- [x] prefix installer and vendoring helper
- [x] dependency-aware selective loader
- [x] compatibility documentation
- [x] release metadata gate and tag workflow
- [x] Bats coverage and maintained example

### M6A — Linux Hardening & Idempotency

- [x] aggregate/per-operation change tracking
- [x] change-aware directory/symlink semantics
- [x] `blm_ensure_mode`
- [x] `blm_ensure_line`
- [x] explicit filesystem dependency checks
- [x] Bats coverage, maintained example and EN/IT documentation
- [ ] process-group hardening for `blm_timeout`

Cross-distribution, macOS and WSL matrices are deferred until those environments can be validated directly.

### M6B — Output & Error Model

- [x] runtime/version diagnostics
- [x] title/section helpers
- [x] explicit non-exiting failure helpers
- [x] deterministic human/plain/JSON presentation behavior
- [x] documented stdout/stderr and machine-readable contracts
- [x] Bats coverage, maintained example and EN/IT documentation
- [ ] richer structured error context
- [ ] color and Unicode policy hardening

### M6C — Advanced System Primitives

- [x] safe backup and non-overwriting copy/move
- [x] SHA-256 checksum helper
- [x] atomic directory locking and `blm_with_lock`
- [x] ownership convergence
- [x] XDG path helpers
- [x] Bats coverage, maintained example and EN/IT documentation

### M6D — Integrations

- [x] Git adapter
- [x] systemd adapter
- [x] Docker / Compose adapter
- [x] DNS / HTTP network readiness checks
- [x] selective integration loader groups
- [x] Bats contract coverage
- [x] maintained M6D example and full-tour coverage
- [x] EN/IT integrations documentation
- [x] deep source-documentation standard for public APIs
- [x] CI source-documentation contract
- [x] repository-wide source comment hardening pass
- [ ] Debian / APT adapter

APT remains deferred from the first M6D slice because package-management policy and environment variance are materially broader than the thin adapters above.

### M6E — Terminal UX

- [x] spinner/progress
- [x] confirm/input/password/select
- [x] panels/tables/tree rendering
- [x] graceful degradation for non-interactive environments
- [x] selective `terminal` loader group
- [x] Bats contract coverage
- [x] maintained M6E example and full-tour coverage
- [x] EN/IT terminal UX documentation

Advanced full-screen TUI behavior, external Gum/fzf backends and richer Unicode decoration remain post-v0.1 candidates.

### M6F — Production Validation

Before `v0.1.0`:

- [ ] integrate Bashloom primitives into at least one real deployment workflow
- [ ] validate against a desktop/installer workflow
- [ ] validate against a system/provisioning workflow
- [ ] revise unstable APIs from field feedback
- [ ] tag the first usable `v0.1.0`

### Quality

- [x] ShellCheck clean for implemented public source
- [x] shfmt clean for implemented public source
- [x] Bats tests for implemented public APIs
- [x] maintained executable examples through M6E
- [x] machine-enforced public API source documentation
- [ ] Bash version matrix
- [ ] cross-distribution matrix
- [ ] documentation parity checks where practical

## v0.2 — Terminal UX

Candidate scope after the first usable foundation release:

- richer panels and tables
- advanced spinners/progress
- timers
- richer prompt/select flows
- optional enhanced backends such as Gum/fzf
- full-screen/cursor-addressed components only if real consumers justify them

## v0.3 — System & Integrations

Candidate scope after the v0.1 foundation stabilizes:

- expanded Git/Docker/systemd adapters
- Debian/APT helpers
- richer network checks

## Later exploration

- human/plain/JSON output refinements
- vendorable module bundler
- generated API reference
- shell completion for a future Bashloom CLI

No item beyond v0.1 is considered committed until specified through documentation and, where appropriate, an ADR.
