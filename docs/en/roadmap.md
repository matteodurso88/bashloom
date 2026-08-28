# Roadmap

Bashloom is in the v0.1 release-candidate validation phase. The roadmap is intentionally capability-driven rather than date-driven.

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
- [x] process-group hardening for external-command `blm_timeout` through GNU `timeout` when available

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
- [x] optional Debian / APT adapter

The APT integration is part of `v0.1.0-rc1`. It uses `apt-get`, `dpkg-query` and `apt-cache`, performs feature dependency checks at call time, never invokes implicit sudo and never refreshes package indexes implicitly.

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
- [x] topology-aware tree rendering
- [x] `BLM_UI_CHARSET=auto|ascii|unicode`
- [x] theme/style registry and multiple component variants
- [x] width-aware terminal layout with deterministic fallback
- [x] dependency-light full-screen TUI foundation
- [x] CI-safe degradation retained
- [x] EN/IT documentation and Bats coverage

Mandatory Gum/fzf backends and broader cosmetic/style expansion remain post-v0.1 candidates.

### M6F — Production Validation

Before `v0.1.0`:

- [x] define field-validation ownership and feedback protocol
- [x] register Oriqo Infrastructure as a deployment consumer
- [x] require consumer findings and improvements to be reported upstream to Bashloom
- [x] complete at least one real deployment validation through the consumer owner's workflow — Oriqo Infrastructure staging PASS
- [ ] validate against a desktop/installer workflow
- [ ] validate against a system/provisioning workflow
- [ ] revise unstable APIs from field feedback where evidence requires it
- [x] publish `v0.1.0-rc1` as the common multi-consumer validation baseline
- [ ] complete the RC multi-consumer validation campaign
- [ ] tag the first stable `v0.1.0`

Historical Oriqo M6F deployment evidence used pin `b6a096ba1feb31f41a639856b29ae07e25ba3676` and completed successfully. The current repository-wide consumer adoption target is `v0.1.0-rc1` at commit `bbbbd9b8e61c7d951b8b9fc8f00c351b50a1bf51`.

See `docs/en/production-validation.md` for the canonical M6F protocol and current evidence state.

### Quality

- [x] ShellCheck clean for implemented public source
- [x] shfmt clean for implemented public source
- [x] Bats tests for implemented public APIs
- [x] maintained executable examples through the RC feature surface
- [x] machine-enforced public API source documentation
- [x] machine-enforced EN/IT public API documentation parity
- [ ] Bash version matrix
- [ ] cross-distribution matrix

## Post-v0.1 contributor roadmap

Post-RC feature work is tracked separately from RC stabilization. See GitHub issue `#28` for the public contributor roadmap and scoped workstreams, including richer terminal identity/color systems, richer presentation components, examples/cookbook, portability/integrations and outreach.

## Later exploration

- richer structured error context
- broader portability matrices
- additional integrations driven by real consumer evidence
- optional terminal UX backends where justified
- shell completion for a future Bashloom CLI

No post-v0.1 item is considered committed until specified through documentation and, where appropriate, an ADR or scoped issue.