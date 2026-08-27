# Bashloom examples / Esempi Bashloom

## English

The `examples/` directory is a maintained part of the Bashloom project. It is intended to serve three purposes:

1. show how the public API is used in realistic shell scripts;
2. provide copyable starting points for users;
3. act as executable integration documentation so public API changes cannot silently break the examples.

### Examples

- `01-command-runtime.sh` — M1 command execution, exit-code preservation, steps and dry-run.
- `02-reliability.sh` — M2 retry, polling, timeout, cleanup and rollback/transactions.
- `03-system-safety.sh` — M3 requirements, permissions, temp resources, idempotent filesystem helpers, atomic writes and paths.
- `full-tour.sh` — non-destructive end-to-end tour of all public primitives implemented through M3.

Run an example from the repository root:

```bash
bash examples/01-command-runtime.sh
bash examples/02-reliability.sh
bash examples/03-system-safety.sh
bash examples/full-tour.sh
```

All filesystem-changing examples operate inside temporary workspaces and clean up after themselves.

### Coverage matrix

| Capability | Focused example | Full tour |
| --- | --- | --- |
| version/capabilities/status | — | yes |
| `blm_run`, dry-run, `blm_step` | `01-command-runtime.sh` | yes |
| retry/wait/timeout | `02-reliability.sh` | yes |
| cleanup/rollback/transactions | `02-reliability.sh` | yes |
| requirement/permission checks | `03-system-safety.sh` | yes |
| temp file/temp directory | `03-system-safety.sh` | yes |
| ensure directory/symlink | `03-system-safety.sh` | yes |
| atomic write | `03-system-safety.sh` | yes |
| path helpers | `03-system-safety.sh` | yes |

### Maintenance rule

Examples are part of the public feature contract. A pull request that adds, removes or changes a public Bashloom API must update the relevant example(s) and this coverage matrix when applicable.

CI checks Bash syntax, ShellCheck and shfmt for the examples and executes `full-tour.sh`. A public API change is therefore not considered complete if the maintained examples no longer work.

Source comments remain in English according to the repository contribution policy. Canonical explanatory documentation is maintained in both English and Italian.

---

## Italiano

La directory `examples/` è una parte mantenuta del progetto Bashloom. Ha tre scopi:

1. mostrare come usare l'API pubblica in script shell realistici;
2. fornire punti di partenza copiabili dagli utenti;
3. funzionare come documentazione di integrazione eseguibile, impedendo che modifiche alle API pubbliche rompano silenziosamente gli esempi.

### Esempi

- `01-command-runtime.sh` — M1: esecuzione comandi, preservazione exit code, step e dry-run.
- `02-reliability.sh` — M2: retry, polling, timeout, cleanup e rollback/transazioni.
- `03-system-safety.sh` — M3: requisiti, permessi, risorse temporanee, filesystem idempotente, atomic write e path.
- `full-tour.sh` — tour end-to-end non distruttivo di tutte le primitive pubbliche implementate fino a M3.

Esecuzione dalla root del repository:

```bash
bash examples/01-command-runtime.sh
bash examples/02-reliability.sh
bash examples/03-system-safety.sh
bash examples/full-tour.sh
```

Tutti gli esempi che modificano il filesystem lavorano dentro workspace temporanei e si puliscono al termine.

### Matrice di copertura

| Capability | Esempio focalizzato | Full tour |
| --- | --- | --- |
| versione/capability/status | — | sì |
| `blm_run`, dry-run, `blm_step` | `01-command-runtime.sh` | sì |
| retry/wait/timeout | `02-reliability.sh` | sì |
| cleanup/rollback/transazioni | `02-reliability.sh` | sì |
| controlli requisiti/permessi | `03-system-safety.sh` | sì |
| file/directory temporanei | `03-system-safety.sh` | sì |
| ensure directory/symlink | `03-system-safety.sh` | sì |
| atomic write | `03-system-safety.sh` | sì |
| helper path | `03-system-safety.sh` | sì |

### Regola di manutenzione

Gli esempi fanno parte del contratto pubblico delle feature. Una pull request che aggiunge, rimuove o modifica un'API pubblica Bashloom deve aggiornare gli esempi pertinenti e, quando necessario, questa matrice di copertura.

La CI verifica sintassi Bash, ShellCheck e shfmt sugli esempi ed esegue `full-tour.sh`. Una modifica dell'API pubblica non è quindi considerata completa se gli esempi mantenuti non funzionano più.

I commenti nei sorgenti restano in inglese secondo la policy di contribuzione del repository. La documentazione esplicativa canonica viene mantenuta sia in inglese sia in italiano.
