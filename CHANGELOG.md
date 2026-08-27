# Changelog / Registro modifiche

All notable changes to Bashloom will be documented in this file.

Tutte le modifiche rilevanti a Bashloom saranno documentate in questo file.

The project follows Semantic Versioning once public versioned releases begin. During the pre-v0.1 foundation phase, entries may describe unreleased development milestones.

Il progetto seguirà il Semantic Versioning a partire dalle release pubbliche versionate. Durante la fase foundation pre-v0.1, le voci possono descrivere milestone di sviluppo non ancora rilasciate.

## [Unreleased] / [Non rilasciato]

### Added / Aggiunto

- Project identity, governance, MIT license and bilingual EN/IT documentation policy.
- Identità del progetto, governance, licenza MIT e policy documentale bilingue EN/IT.
- M1 command runtime, M2 reliability, M3 system safety, M4 runtime state and M5 consumption foundations.
- Foundation M1 command runtime, M2 reliability, M3 system safety, M4 runtime state e M5 consumption.
- M6A idempotency and change tracking.
- M6A idempotenza e change tracking.
- M6B output/error model with diagnostics and explicit non-exiting failure helpers.
- M6B output/error model con diagnostica e failure helper espliciti senza exit impliciti.
- M6C advanced filesystem, locking, ownership and XDG primitives.
- M6C primitive filesystem avanzate, locking, ownership e XDG.
- M6D Git, systemd, Docker Compose and network integrations.
- M6D integrazioni Git, systemd, Docker Compose e rete.
- Repository-wide deep source-documentation standard with CI enforcement.
- Standard repository-wide di documentazione profonda in-source con enforcement CI.
- M6E terminal UX: prompt, confirm, password, select, progress, spinner, panel, table and tree primitives.
- M6E terminal UX: primitive prompt, confirm, password, select, progress, spinner, panel, table e tree.
- M6E.1 rich terminal rendering with visual progress bars, animated Unicode/ASCII spinner, auto-sized panels, aligned tables and branch-marked trees.
- M6E.1 rendering terminale rich con progress bar visuali, spinner Unicode/ASCII animato, panel auto-dimensionati, tabelle allineate e tree con branch marker.
- `BLM_UI_CHARSET=auto|ascii|unicode`, `BLM_UI_STYLE=rich|minimal` and configurable `BLM_PROGRESS_WIDTH`.
- `BLM_UI_CHARSET=auto|ascii|unicode`, `BLM_UI_STYLE=rich|minimal` e `BLM_PROGRESS_WIDTH` configurabile.
- Maintained `examples/11-rich-terminal.sh` visual showcase with deterministic CI fallback.
- Showcase visuale mantenuta `examples/11-rich-terminal.sh` con fallback deterministico in CI.

### Changed / Modificato

- Filesystem helpers check feature-specific dependencies such as `readlink` and `rm` explicitly when needed.
- Gli helper filesystem verificano esplicitamente dipendenze feature-specific come `readlink` e `rm` quando necessarie.
- The `system` loader group includes advanced filesystem, locking and XDG helpers; `all` includes integrations and terminal UX.
- Il gruppo loader `system` include filesystem avanzato, locking e XDG; `all` include integrazioni e terminal UX.
- Existing public source files use contract-oriented docblocks covering purpose, usage, statuses, output, side effects, dependencies, security and non-obvious invariants.
- I sorgenti pubblici usano docblock orientati al contratto con scopo, uso, status, output, side effect, dipendenze, sicurezza e invarianti non ovvie.
- `blm_require_env` validates environment-variable names before indirect expansion.
- `blm_require_env` valida i nomi delle variabili environment prima dell'espansione indiretta.
- `examples/10-terminal-ux.sh` now evaluates TTY state outside command substitution so it reports the real terminal capability.
- `examples/10-terminal-ux.sh` valuta ora lo stato TTY fuori dalla command substitution, riportando la reale capability del terminale.
