# Changelog / Registro modifiche

All notable changes to Bashloom are documented in this file.

Tutte le modifiche rilevanti a Bashloom sono documentate in questo file.

The project follows Semantic Versioning for public versioned releases.

Il progetto segue il Semantic Versioning per le release pubbliche versionate.

## [Unreleased] / [Non rilasciato]

No changes after the v0.1.0-rc1 freeze candidate yet.

Nessuna modifica successiva al candidato al freeze v0.1.0-rc1 al momento.

## [0.1.0-rc1] - 2026-08-28

First public release-candidate baseline for multi-consumer field validation.

Prima baseline release candidate pubblica per la validazione sul campo multi-consumer.

### Added / Aggiunto

- M1 command runtime with argv-safe execution, dry-run support and exact exit-status preservation.
- Runtime comandi M1 con esecuzione argv-safe, supporto dry-run e preservazione esatta degli exit status.
- M2 reliability primitives: retry, wait, timeout, cleanup and transaction/rollback helpers.
- Primitive reliability M2: retry, wait, timeout, cleanup e helper transaction/rollback.
- M3/M6 system and filesystem primitives for requirements, temporary resources, paths, idempotent convergence, safe copy/move, checksums, locking, ownership, XDG and atomic replacement.
- Primitive sistema e filesystem M3/M6 per requirements, risorse temporanee, path, convergenza idempotente, copy/move sicuri, checksum, locking, ownership, XDG e sostituzione atomica.
- Runtime state layer with human/plain/JSON output, logging, environment helpers, literal key=value config and persistent atomic state.
- Layer runtime state con output human/plain/JSON, logging, helper environment, config key=value letterale e stato persistente atomico.
- Selective dependency-aware loader, local installer, pinned vendoring with integrity verification and release archive tooling.
- Loader selettivo dependency-aware, installer locale, vendoring pinnato con verifica integrità e tooling per gli archivi release.
- Git, systemd, Docker Compose and network integrations.
- Integrazioni Git, systemd, Docker Compose e network.
- Optional Debian-family APT integration using `apt-get`, `dpkg-query` and `apt-cache` without implicit sudo or hidden index refreshes.
- Integrazione APT opzionale per sistemi Debian-family tramite `apt-get`, `dpkg-query` e `apt-cache`, senza sudo implicito né refresh nascosti degli indici.
- Terminal UX primitives for prompts, confirmation, password input, selection, presentation, progress, spinners and trees.
- Primitive Terminal UX per prompt, conferma, password, selezione, presentation, progress, spinner e tree.
- Theme/style registry with `default`, `modern`, `minimal`, `ascii` and `ci` presets plus per-component/per-call overrides.
- Registry theme/style con preset `default`, `modern`, `minimal`, `ascii` e `ci` più override per componente e per chiamata.
- Multiple spinner, progress, panel, table and tree visual variants without public API proliferation.
- Varianti visuali multiple per spinner, progress, panel, table e tree senza proliferazione delle API pubbliche.
- Width-aware terminal layout via `blm_display_width`, using Unicode-aware measurement when Python is available and deterministic fallback otherwise.
- Layout terminale width-aware tramite `blm_display_width`, con misura Unicode-aware quando Python è disponibile e fallback deterministico negli altri casi.
- Advanced topology-aware `blm_tree_view` rendering with sibling endings and continuation branches.
- Rendering avanzato topology-aware `blm_tree_view` con terminazioni sibling e continuation branch.
- Dependency-light full-screen TUI foundation with alternate-screen lifecycle, cursor movement, size detection and key normalization.
- Foundation TUI full-screen dependency-light con lifecycle alternate-screen, movimento cursore, rilevamento dimensioni e normalizzazione tasti.
- Repository-wide public source documentation contract and permanent EN/IT public-API documentation parity gate.
- Contratto repository-wide di documentazione pubblica in-source e gate permanente di parità documentale API pubbliche EN/IT.

### Changed / Modificato

- `blm_timeout` uses GNU coreutils `timeout` for external executables when available so enforced deadlines can terminate command descendants; shell functions/builtins retain the Bash-compatible direct-child backend.
- `blm_timeout` usa GNU coreutils `timeout` per gli eseguibili esterni quando disponibile, così le deadline applicate possono terminare i discendenti del comando; funzioni shell/builtin mantengono il backend direct-child compatibile Bash.
- Numeric permission modes are validated as octal before filesystem mutation.
- I permission mode numerici vengono validati come ottali prima delle mutazioni filesystem.
- `blm_ensure_line` explicitly rejects multiline payloads.
- `blm_ensure_line` rifiuta esplicitamente payload multilinea.
- Core JSON escaping covers all C0 controls representable by Bash variables while preserving printable Unicode.
- L'escaping JSON del core copre tutti i control C0 rappresentabili dalle variabili Bash preservando l'Unicode stampabile.
- `blm_atomic_write` is explicitly defined as same-filesystem atomic replacement, not an fsync/power-loss durability primitive.
- `blm_atomic_write` è esplicitamente definita come sostituzione atomica sullo stesso filesystem, non come primitiva di durabilità fsync/power-loss.
- Directory locks deliberately do not perform automatic stale-lock recovery; liveness policy remains application-owned.
- I directory lock deliberatamente non effettuano recovery automatico degli stale lock; la policy di liveness resta responsabilità dell'applicazione.
- `BLM_LOG_FILE` never creates parent directories implicitly.
- `BLM_LOG_FILE` non crea mai implicitamente le directory parent.

### Validation / Validazione

- Bash syntax, ShellCheck, shfmt, source-documentation contract, public-API EN/IT documentation contract, Bats and maintained examples are merge-blocking CI gates.
- Sintassi Bash, ShellCheck, shfmt, contratto documentazione sorgente, contratto documentazione API pubbliche EN/IT, Bats ed esempi mantenuti sono gate CI bloccanti per il merge.
- The RC convergence baseline passes 118 Bats tests before release-preparation changes; release-specific regression tests are added on top of that baseline.
- La baseline di convergenza RC supera 118 test Bats prima delle modifiche di release preparation; i test di regressione specifici per la release vengono aggiunti sopra tale baseline.
