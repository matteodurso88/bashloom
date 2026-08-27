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
- `blm_require_root` and readable/writable/executable permission checks.
- `blm_require_root` e controlli permessi readable/writable/executable.
- Secure temporary file and directory helpers with restrictive permissions.
- Helper sicuri per file e directory temporanei con permessi restrittivi.
- Idempotent directory and symlink helpers.
- Helper idempotenti per directory e symlink.
- Atomic file replacement with producer-failure protection and existing-mode preservation on GNU/Linux.
- Sostituzione atomica dei file con protezione dai fallimenti del producer e preservazione dei permessi esistenti su GNU/Linux.
- Pure-Bash lexical path helpers and dependency-free entrypoint path resolution.
- Helper path lessicali pure-Bash e risoluzione path dell'entrypoint senza dipendenze esterne.
- System-safety API documentation in English and Italian.
- Documentazione API system-safety in inglese e italiano.
- Human/plain/JSON output modes and key/value machine output.
- Modalità output human/plain/JSON e output key/value machine-readable.
- Filtered logging with optional timestamped file persistence.
- Logging filtrato con persistenza opzionale su file con timestamp.
- Safe environment helpers for exact values and booleans.
- Helper environment sicuri per valori esatti e booleani.
- Safe literal `key=value` configuration parsing without `source` or `eval`.
- Parsing sicuro della configurazione letterale `key=value` senza `source` o `eval`.
- Atomic persistent state get/set/delete primitives.
- Primitive atomiche get/set/delete per stato persistente.
- Runtime-state API documentation in English and Italian.
- Documentazione API runtime-state in inglese e italiano.
- Dependency-aware selective module loader with `blm_load`.
- Loader selettivo dei moduli con dipendenze dichiarate tramite `blm_load`.
- Explicit prefix installer with no implicit privilege escalation.
- Installer sotto prefix esplicito senza escalation implicita dei privilegi.
- Vendoring helper for pinned self-contained runtime copies.
- Helper di vendoring per copie runtime autosufficienti e fissate nel progetto consumer.
- EN/IT consumption and compatibility documentation.
- Documentazione EN/IT su consumption e compatibilità.
- Version metadata release gate and guarded tag-based GitHub Release workflow with SHA-256 checksums.
- Release gate sui metadata di versione e workflow GitHub Release su tag con checksum SHA-256.
- Aggregate and per-operation change tracking with `BLM_CHANGED` and `BLM_LAST_CHANGED`.
- Change tracking aggregato e per singola operazione tramite `BLM_CHANGED` e `BLM_LAST_CHANGED`.
- `blm_change_reset`, `blm_changed` and `blm_last_changed` convergence helpers.
- Helper di convergenza `blm_change_reset`, `blm_changed` e `blm_last_changed`.
- `blm_ensure_mode` and exact-line `blm_ensure_line` idempotency primitives.
- Primitive idempotenti `blm_ensure_mode` e `blm_ensure_line` per righe esatte.
- Change-aware directory and symlink ensure semantics.
- Semantica changed/no-op per ensure directory e symlink.
- EN/IT idempotency documentation and maintained executable example.
- Documentazione EN/IT sull'idempotenza ed esempio eseguibile mantenuto.
- `blm_title` and `blm_section` presentation helpers for human/plain/JSON output.
- Helper di presentazione `blm_title` e `blm_section` per output human/plain/JSON.
- `blm_diagnostics` runtime/version diagnostics using the configured output mode.
- Diagnostica runtime/versione `blm_diagnostics` coerente con la modalità output configurata.
- `blm_fail` and `blm_usage_error` explicit non-exiting error helpers.
- Helper di errore espliciti senza exit impliciti `blm_fail` e `blm_usage_error`.
- EN/IT output/error model documentation and maintained executable example.
- Documentazione EN/IT del modello output/error ed esempio eseguibile mantenuto.
- Maintained executable examples through M6B with CI full-tour execution.
- Esempi eseguibili mantenuti fino a M6B con esecuzione full-tour in CI.
- Bats contract tests for command runtime, reliability, system safety, runtime state, consumption, idempotency and output/error paths.
- Test contrattuali Bats per command runtime, reliability, system safety, runtime state, consumption, idempotenza e percorsi output/error.
- Bats smoke tests and CI foundation.
- Smoke test Bats e foundation CI.

### Changed / Modificato

- Filesystem helpers now check `readlink` and `rm` explicitly when those utilities are required.
- Gli helper filesystem verificano ora esplicitamente `readlink` e `rm` quando queste utility sono necessarie.
