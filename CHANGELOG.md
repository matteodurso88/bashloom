# Changelog / Registro modifiche

All notable changes to Bashloom will be documented in this file.

Tutte le modifiche rilevanti a Bashloom saranno documentate in questo file.

The project follows Semantic Versioning once public versioned releases begin. During the pre-v0.1 foundation phase, entries may describe unreleased development milestones.

Il progetto seguirà il Semantic Versioning a partire dalle release pubbliche versionate. Durante la fase foundation pre-v0.1, le voci possono descrivere milestone di sviluppo non ancora rilasciate.

## [Unreleased] / [Non rilasciato]

### Added / Aggiunto

- Project identity, ownership and technical-account model.
- Identità del progetto, ownership e modello di account tecnico.
- MIT license.
- Licenza MIT.
- Bilingual EN/IT documentation policy with contributor language accessibility and optional community translations.
- Policy documentale bilingue EN/IT con accessibilità linguistica per i contributor e traduzioni community opzionali.
- Architecture, governance and design principles documentation.
- Documentazione di architettura, governance e principi di progettazione.
- Initial source-safe runtime entrypoint.
- Runtime entrypoint iniziale source-safe.
- Version and terminal capability primitives.
- Primitive iniziali di versione e capability terminale.
- Basic status rendering and requirement checks.
- Rendering base degli status e requirement check.
- Contributor issue and pull-request templates with maintainer final-review policy.
- Template contributor per issue e pull request con policy di revisione finale dei maintainer.
- `blm_run` with exact exit-status preservation and dry-run support.
- `blm_run` con preservazione esatta dell'exit status e supporto dry-run.
- `blm_step` command lifecycle helper.
- Helper `blm_step` per il lifecycle dei comandi.
- `blm_retry` with attempts, delay and integer backoff.
- `blm_retry` con tentativi, delay e backoff intero.
- `blm_wait_for` polling with timeout status `124`.
- Polling `blm_wait_for` con status timeout `124`.
- `blm_timeout` with TERM/grace/KILL lifecycle and documented subshell isolation.
- `blm_timeout` con lifecycle TERM/grace/KILL e isolamento in subshell documentato.
- LIFO cleanup stack with explicit trap installation and caller-trap protection.
- Cleanup stack LIFO con installazione esplicita delle trap e protezione delle trap del caller.
- LIFO rollback stack and explicit transaction begin/commit/rollback primitives.
- Rollback stack LIFO e primitive esplicite begin/commit/rollback per le transazioni.
- Runtime/reliability API documentation in English and Italian.
- Documentazione API runtime/reliability in inglese e italiano.
- Bats contract tests for command runtime, retry/wait, timeout, cleanup and rollback.
- Test contrattuali Bats per command runtime, retry/wait, timeout, cleanup e rollback.
- Bats smoke tests and CI foundation.
- Smoke test Bats e foundation CI.
