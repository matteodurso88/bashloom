# Roadmap

Bashloom is currently in the foundation / early v0.1 implementation phase. The roadmap is intentionally capability-driven rather than date-driven.

## pre-v0.1 — Foundation

- [x] project identity and ownership model
- [x] EN/IT documentation policy
- [x] architecture baseline
- [x] source-safe runtime entrypoint
- [x] version metadata
- [x] basic capability detection/status/requirements
- [x] Bats smoke tests
- [x] ShellCheck/shfmt/Bats CI
- [x] contributor templates
- [x] draft v0.1 API specification
- [ ] compatibility test matrix

## v0.1 — Reliable Shell Foundation

### M1 — Command Runtime

- [x] `blm_run`, exact exit status, dry-run and `blm_step`
- [x] caller `set -e` compatibility
- [x] no `eval` / argv-safe execution

### M2 — Reliability

- [x] retry/wait/timeout
- [x] LIFO cleanup/rollback and explicit transactions
- [x] Bats coverage and EN/IT documentation

### M3 — System Safety

- [x] root/permission requirements
- [x] secure temp resources
- [x] directory/symlink convergence and atomic writes
- [x] lexical path helpers
- [x] Bats coverage and EN/IT documentation

### M4 — Runtime State

- [x] logging/environment helpers
- [x] safe literal config and atomic state
- [x] human/plain/JSON output
- [x] tests, example and EN/IT docs

### M5 — Consumption

- [x] installer/vendoring
- [x] selective loader
- [x] compatibility docs and release gate/workflow
- [x] tests and maintained example

### M6A — Linux Hardening & Idempotency

- [x] aggregate/per-operation change tracking
- [x] change-aware directory/symlink semantics
- [x] `blm_ensure_mode`, `blm_ensure_line`
- [x] explicit filesystem dependency checks
- [x] tests/example/docs
- [ ] process-group hardening for `blm_timeout`

Cross-distribution, macOS and WSL matrices are deferred until those environments can be validated directly.

### M6B — Output & Error Model

- [x] diagnostics and title/section helpers
- [x] explicit non-exiting failure helpers
- [x] deterministic human/plain/JSON contracts
- [x] tests/example/docs
- [ ] richer structured error context

### M6C — Advanced System Primitives

- [x] safe backup/copy/move and SHA-256
- [x] directory locking / `blm_with_lock`
- [x] ownership convergence and XDG paths
- [x] tests/example/docs

### M6D — Integrations

- [x] Git adapter
- [x] systemd adapter
- [x] Docker / Compose adapter
- [x] DNS / HTTP readiness
- [x] selective integration groups
- [x] deep source-documentation standard and CI contract
- [x] repository-wide source comment hardening
- [ ] Debian / APT adapter

APT remains deferred because package-management policy and environment variance are materially broader than the thin adapters above.

### M6E — Terminal UX Foundation

- [x] spinner/progress
- [x] confirm/input/password/select
- [x] panels/tables/tree
- [x] deterministic non-interactive degradation
- [x] selective `terminal` loader group
- [x] tests/example/full-tour/docs

### M6E.1 — Rich Terminal Rendering

- [x] visual fixed-width progress bar
- [x] animated Unicode/ASCII spinner
- [x] auto-sized rich panels
- [x] aligned tab-delimited tables
- [x] branch-marked tree rendering
- [x] `BLM_UI_CHARSET=auto|ascii|unicode`
- [x] `BLM_UI_STYLE=rich|minimal`
- [x] `BLM_PROGRESS_WIDTH`
- [x] dedicated interactive showcase `examples/11-rich-terminal.sh`
- [x] CI-safe degradation retained
- [x] EN/IT documentation and Bats coverage

Full-screen TUI behavior, terminal mouse handling and mandatory Gum/fzf backends remain post-v0.1 candidates.

### M6F — Production Validation

Before `v0.1.0`:

- [ ] integrate Bashloom into at least one real deployment workflow
- [ ] validate against a desktop/installer workflow
- [ ] validate against a system/provisioning workflow
- [ ] revise unstable APIs from field feedback
- [ ] tag the first usable `v0.1.0`

### Quality

- [x] ShellCheck clean for implemented public source
- [x] shfmt clean for implemented public source
- [x] Bats tests for implemented public APIs
- [x] maintained executable examples through M6E.1
- [x] machine-enforced public API source documentation
- [ ] Bash version matrix
- [ ] cross-distribution matrix
- [ ] documentation parity checks where practical

## v0.2 — Terminal UX

Candidate scope after the first usable foundation release: timers, richer prompt/select flows, optional Gum/fzf backends and full-screen/cursor-addressed components only when real consumers justify them.

## v0.3 — System & Integrations

Candidate scope after v0.1 stabilizes: expanded Git/Docker/systemd adapters, Debian/APT helpers and richer network checks.

## Later exploration

- human/plain/JSON refinements
- vendorable module bundler
- generated API reference
- shell completion for a future Bashloom CLI

No item beyond v0.1 is considered committed until specified through documentation and, where appropriate, an ADR.
