# Contributing to Bashloom / Contribuire a Bashloom

## English

Thank you for considering a contribution to Bashloom.

Bashloom is an Italian open-source project with an international contribution model. The repository is owned by Matteo D'Urso (`matteodurso88`); day-to-day technical work may be performed by the technical account Developer Oriqo (`dev-oriqo`).

### Contribution rules

- Source code, identifiers, commit messages and code comments must be in **English**.
- User-facing documentation must be kept in **English and Italian**.
- Any API or behavior change must update the corresponding EN/IT documentation in the same pull request.
- Public functions use the `blm_*` namespace. Internal functions use `_blm_*`.
- New public APIs require tests and documentation.
- Avoid introducing mandatory runtime dependencies into the core.
- Do not modify the caller's shell options, traps or global environment implicitly.
- Preserve command exit semantics; UI must never hide failures.
- Prefer small, composable primitives over project-specific helpers.

### Before opening a pull request

Run, when available:

```bash
bash -n src/bashloom.sh
shellcheck src/**/*.sh tests/**/*.bash
shfmt -d .
bats tests
```

### Pull requests

A pull request should explain:

1. what problem it solves;
2. why the change belongs in Bashloom;
3. whether public behavior changes;
4. which tests were added or updated;
5. which EN/IT documentation files were updated.

### Documentation parity

English and Italian documentation are peers. Neither language is considered secondary. If a translated document cannot be updated in the same change, the PR should not be considered complete.

---

## Italiano

Grazie per voler contribuire a Bashloom.

Bashloom è un progetto open source italiano con un modello di contribuzione internazionale. Il repository è di proprietà di Matteo D'Urso (`matteodurso88`); le attività tecniche quotidiane possono essere svolte tramite l'account tecnico Developer Oriqo (`dev-oriqo`).

### Regole di contribuzione

- Sorgenti, identificatori, commit message e commenti nel codice devono essere in **inglese**.
- La documentazione destinata agli utenti deve essere mantenuta in **inglese e italiano**.
- Ogni modifica ad API o comportamento deve aggiornare la relativa documentazione EN/IT nella stessa pull request.
- Le funzioni pubbliche usano il namespace `blm_*`. Le funzioni interne usano `_blm_*`.
- Le nuove API pubbliche richiedono test e documentazione.
- Evitare dipendenze runtime obbligatorie nel core.
- Non modificare implicitamente shell option, trap o ambiente globale del chiamante.
- Preservare la semantica degli exit code; la UI non deve mai nascondere errori.
- Preferire primitive piccole e componibili rispetto a helper specifici di un singolo progetto.

### Prima di aprire una pull request

Eseguire, quando disponibili:

```bash
bash -n src/bashloom.sh
shellcheck src/**/*.sh tests/**/*.bash
shfmt -d .
bats tests
```

### Pull request

Una pull request dovrebbe spiegare:

1. quale problema risolve;
2. perché la modifica appartiene a Bashloom;
3. se cambia il comportamento pubblico;
4. quali test sono stati aggiunti o aggiornati;
5. quali file di documentazione EN/IT sono stati aggiornati.

### Parità documentale

La documentazione inglese e italiana ha pari dignità. Nessuna delle due lingue è considerata secondaria. Se non è possibile aggiornare entrambe nella stessa modifica, la PR non dovrebbe essere considerata completa.
