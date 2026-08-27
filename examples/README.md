# Bashloom examples / Esempi Bashloom

## English

The `examples/` directory is a maintained public surface: examples are copyable usage references and executable integration documentation. Public API changes must keep the relevant focused example, this matrix and `full-tour.sh` aligned.

### Examples

- `00-foundation.sh` — version, capabilities and status output.
- `01-command-runtime.sh` — M1 command execution, status preservation and dry-run.
- `02-reliability.sh` — M2 retry, wait, timeout, cleanup and rollback.
- `03-system-safety.sh` — M3 requirements, temp resources, filesystem and paths.
- `04-runtime-state.sh` — M4 output, logging, environment, config and state.
- `05-consumption.sh` — M5 selective loading, installation, vendoring and release gate.
- `06-idempotency.sh` — M6A convergence and change tracking.
- `07-output-error-model.sh` — M6B presentation, diagnostics and explicit failures.
- `08-advanced-system.sh` — M6C backup/copy/move, checksum, locks, ownership and XDG.
- `09-integrations.sh` — M6D Git, Docker/systemd capability detection and network readiness.
- `10-terminal-ux.sh` — M6E CI-safe terminal UX foundation and non-interactive degradation.
- `11-rich-terminal.sh` — M6E.1 visual showcase: rich panel, aligned table, tree, progress bar and animated spinner.
- `full-tour.sh` — non-destructive end-to-end tour of all maintained capabilities.

Run from the repository root:

```bash
bash examples/10-terminal-ux.sh
bash examples/11-rich-terminal.sh
bash examples/full-tour.sh
```

`11-rich-terminal.sh` is intended to be run directly in a real terminal. In CI or through a pipe it degrades deterministically and does not block.

### Coverage matrix

| Capability | Focused example | Full tour |
| --- | --- | --- |
| version/capabilities/status | `00-foundation.sh` | yes |
| `blm_run`, dry-run, `blm_step` | `01-command-runtime.sh` | yes |
| retry/wait/timeout + cleanup/rollback | `02-reliability.sh` | yes |
| requirements/temp/filesystem/path | `03-system-safety.sh` | yes |
| output/logging/env/config/state | `04-runtime-state.sh` | yes |
| loader/install/vendor/release gate | `05-consumption.sh` | yes |
| change tracking + idempotent convergence | `06-idempotency.sh` | yes |
| presentation/diagnostics/error status | `07-output-error-model.sh` | yes |
| backup/copy/move/checksum/locks/owner/XDG | `08-advanced-system.sh` | yes |
| Git/Docker/systemd/network integrations | `09-integrations.sh` | yes |
| prompt/confirm/password/select | `10-terminal-ux.sh` | yes |
| deterministic terminal degradation | `10-terminal-ux.sh` | yes |
| rich panel/table/tree | `11-rich-terminal.sh` | yes |
| visual progress bar / animated spinner | `11-rich-terminal.sh` | yes |
| Unicode/ASCII UI fallback | `11-rich-terminal.sh` | yes |

### Maintenance rule

CI checks Bash syntax, ShellCheck, shfmt, the public source-documentation contract, Bats suites and `full-tour.sh`. A public API change is incomplete if maintained examples or source documentation no longer satisfy those gates.

---

## Italiano

La directory `examples/` è una superficie pubblica mantenuta: gli esempi sono riferimenti copiabili e documentazione di integrazione eseguibile. Le modifiche alle API pubbliche devono mantenere allineati l'esempio focalizzato, questa matrice e `full-tour.sh`.

### Esempi

- `00-foundation.sh` — versione, capability e status output.
- `01-command-runtime.sh` — M1 esecuzione comandi, preservazione status e dry-run.
- `02-reliability.sh` — M2 retry, wait, timeout, cleanup e rollback.
- `03-system-safety.sh` — M3 requisiti, temp, filesystem e path.
- `04-runtime-state.sh` — M4 output, logging, environment, config e stato.
- `05-consumption.sh` — M5 loader selettivo, installazione, vendoring e release gate.
- `06-idempotency.sh` — M6A convergenza e change tracking.
- `07-output-error-model.sh` — M6B presentazione, diagnostica e failure espliciti.
- `08-advanced-system.sh` — M6C backup/copy/move, checksum, lock, ownership e XDG.
- `09-integrations.sh` — M6D Git, capability Docker/systemd e readiness di rete.
- `10-terminal-ux.sh` — M6E foundation terminal UX CI-safe e degradazione non-interattiva.
- `11-rich-terminal.sh` — M6E.1 showcase visuale: panel rich, tabella allineata, tree, progress bar e spinner animato.
- `full-tour.sh` — tour end-to-end non distruttivo di tutte le capability mantenute.

Dalla root:

```bash
bash examples/10-terminal-ux.sh
bash examples/11-rich-terminal.sh
bash examples/full-tour.sh
```

`11-rich-terminal.sh` è pensato per essere lanciato direttamente in un terminale reale. In CI o pipe degrada in modo deterministico e non blocca.

### Matrice di copertura

| Capability | Esempio focalizzato | Full tour |
| --- | --- | --- |
| versione/capability/status | `00-foundation.sh` | sì |
| `blm_run`, dry-run, `blm_step` | `01-command-runtime.sh` | sì |
| retry/wait/timeout + cleanup/rollback | `02-reliability.sh` | sì |
| requisiti/temp/filesystem/path | `03-system-safety.sh` | sì |
| output/logging/env/config/stato | `04-runtime-state.sh` | sì |
| loader/install/vendor/release gate | `05-consumption.sh` | sì |
| change tracking + convergenza idempotente | `06-idempotency.sh` | sì |
| presentazione/diagnostica/status errore | `07-output-error-model.sh` | sì |
| backup/copy/move/checksum/lock/owner/XDG | `08-advanced-system.sh` | sì |
| integrazioni Git/Docker/systemd/rete | `09-integrations.sh` | sì |
| prompt/confirm/password/select | `10-terminal-ux.sh` | sì |
| degradazione terminale deterministica | `10-terminal-ux.sh` | sì |
| panel/table/tree rich | `11-rich-terminal.sh` | sì |
| progress bar visuale / spinner animato | `11-rich-terminal.sh` | sì |
| fallback UI Unicode/ASCII | `11-rich-terminal.sh` | sì |

### Regola di manutenzione

La CI verifica sintassi Bash, ShellCheck, shfmt, contratto di documentazione pubblica in-source, suite Bats e `full-tour.sh`. Una modifica alle API pubbliche è incompleta se esempi mantenuti o documentazione source non superano questi gate.
