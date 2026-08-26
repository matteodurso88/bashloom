# Roadmap

Bashloom is currently in the foundation phase. The roadmap is intentionally capability-driven rather than date-driven.

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
- [ ] contributor issue and pull-request templates
- [ ] API specification for v0.1 primitives
- [ ] compatibility test matrix

## v0.1 — Reliable Shell Foundation

Planned public capabilities:

### Core

- terminal capability model
- output mode model
- color and Unicode policy
- runtime/version diagnostics

### UI

- info/success/warn/error
- title/section
- step lifecycle
- key/value output

### Ops

- require command/file/directory/environment
- command runner with exact exit-code preservation
- retry
- wait-until with timeout and interval
- cleanup stack
- explicit error/exit helpers

### System

- safe temporary directory/file helpers
- ensure directory
- atomic file write
- permission checks
- path helpers

### Quality

- ShellCheck clean
- shfmt clean
- Bats tests for public APIs
- Bash version matrix
- documentation parity checks where practical

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

- transactional rollback stack
- dry-run execution model
- human/plain/JSON output modes
- vendorable module bundler
- generated API reference
- shell completion for a future Bashloom CLI

No item beyond v0.1 is considered committed until specified through documentation and, where appropriate, an ADR.
