# Changelog / Registro modifiche

All notable changes to Bashloom will be documented in this file.

Tutte le modifiche rilevanti a Bashloom saranno documentate in questo file.

The project follows Semantic Versioning once public versioned releases begin. During the pre-v0.1 foundation phase, entries may describe unreleased development milestones.

Il progetto seguirà il Semantic Versioning a partire dalle release pubbliche versionate. Durante la fase foundation pre-v0.1, le voci possono descrivere milestone di sviluppo non ancora rilasciate.

## [Unreleased] / [Non rilasciato]

### Added / Aggiunto

- Project identity, governance, MIT license and bilingual EN/IT documentation policy.
- Identità del progetto, governance, licenza MIT e policy documentale bilingue EN/IT.
- Source-safe runtime entrypoint, version metadata, capability/status/requirement primitives and CI foundation.
- Runtime entrypoint source-safe, metadata versione, primitive capability/status/requirement e foundation CI.
- M1 command runtime: `blm_run`, dry-run, exact exit-status preservation and `blm_step`.
- M1 command runtime: `blm_run`, dry-run, preservazione esatta exit status e `blm_step`.
- M2 reliability: retry, wait, timeout, cleanup, rollback and explicit transactions.
- M2 reliability: retry, wait, timeout, cleanup, rollback e transazioni esplicite.
- M3 system safety: permission/root checks, secure temp resources, idempotent filesystem, atomic writes and lexical paths.
- M3 system safety: controlli permessi/root, risorse temporanee sicure, filesystem idempotente, atomic write e path lessicali.
- M4 runtime state: human/plain/JSON output, logging, environment helpers, literal config and atomic persistent state.
- M4 runtime state: output human/plain/JSON, logging, helper environment, config letterale e stato persistente atomico.
- M5 consumption: selective module loader, prefix installer, vendoring, compatibility docs and guarded tag release workflow.
- M5 consumption: loader selettivo, installer prefix, vendoring, documentazione compatibilità e workflow release tag protetto.
- M6A idempotency: aggregate/per-operation change tracking, `blm_ensure_mode` and `blm_ensure_line`.
- M6A idempotenza: change tracking aggregato/per operazione, `blm_ensure_mode` e `blm_ensure_line`.
- M6B output/error model: title/section, diagnostics, `blm_fail` and `blm_usage_error`.
- M6B output/error model: title/section, diagnostica, `blm_fail` e `blm_usage_error`.
- M6C advanced system: non-overwriting backup/copy/move, SHA-256, directory locks, ownership convergence and XDG paths.
- M6C advanced system: backup/copy/move senza sovrascrittura, SHA-256, lock directory, convergenza ownership e path XDG.
- M6D Git integration: repository root/current branch/clean-state queries and clean-worktree enforcement.
- M6D integrazione Git: root repository/branch corrente/stato clean e enforcement worktree pulita.
- M6D systemd integration: active predicate, readiness wait, restart and reload without implicit privilege escalation.
- M6D integrazione systemd: predicato active, wait readiness, restart e reload senza escalation implicita.
- M6D Docker Compose integration using the modern `docker compose` plugin with argv-safe forwarding.
- M6D integrazione Docker Compose basata sul moderno plugin `docker compose` con forwarding argv-safe.
- M6D network readiness: NSS-aware DNS resolution and curl-based HTTP readiness/wait primitives.
- M6D readiness rete: risoluzione DNS conforme a NSS e primitive readiness/wait HTTP basate su curl.
- Selective loader groups `git`, `systemd`, `docker`, `network` and aggregate `integrations`.
- Gruppi loader selettivi `git`, `systemd`, `docker`, `network` e aggregato `integrations`.
- Repository-wide deep source-documentation standard for public APIs, with EN/IT policy and CI enforcement through `tools/check-source-docs.sh`.
- Standard repository-wide di documentazione profonda in-source per API pubbliche, con policy EN/IT e gate CI tramite `tools/check-source-docs.sh`.
- Maintained executable examples through M6D and Bats contract coverage for implemented integration paths.
- Esempi eseguibili mantenuti fino a M6D e copertura contrattuale Bats per le integrazioni implementate.

### Changed / Modificato

- Filesystem helpers check feature-specific dependencies such as `readlink` and `rm` explicitly when needed.
- Gli helper filesystem verificano esplicitamente dipendenze feature-specific come `readlink` e `rm` quando necessarie.
- The `system` loader group includes advanced filesystem, locking and XDG helpers; `all` now also includes the integration groups.
- Il gruppo loader `system` include filesystem avanzato, locking e XDG; `all` include ora anche i gruppi integrazione.
- Existing public source files were expanded from minimal comments to contract-oriented docblocks covering purpose, usage, statuses, output, side effects, dependencies, security and non-obvious invariants.
- I sorgenti pubblici esistenti sono passati da commenti minimi a docblock orientati al contratto con scopo, uso, status, output, side effect, dipendenze, sicurezza e invarianti non ovvie.
- `blm_require_env` now validates the environment-variable name before indirect expansion.
- `blm_require_env` valida ora il nome della variabile environment prima dell'espansione indiretta.
