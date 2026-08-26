# Contributing to Bashloom / Contribuire a Bashloom

## English

Thank you for considering a contribution to Bashloom.

Bashloom is an Italian open-source project with an international contribution model. The repository is owned by Matteo D'Urso (`matteodurso88`); day-to-day technical work may be performed by the technical account Developer Oriqo (`dev-oriqo`). See `GOVERNANCE.md` for the authoritative project governance rules.

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

### Licensing of contributions

Bashloom is licensed under the MIT License.

By submitting a contribution, you agree that your contribution may be distributed under the same MIT License as the project. You retain copyright in your original contribution unless a different written agreement explicitly states otherwise.

No Contributor License Agreement (CLA) is currently required.

### Maintainer final review

External contributions are proposals for inclusion in the official Bashloom codebase. Opening a pull request does not create a right to merge.

Every external contribution requires final maintainer review. Maintainers may request changes, reject, split, squash, refactor, adapt, rewrite or reimplement a proposed contribution before integration. They may also change naming, API shape, tests or documentation to preserve security, portability, maintainability and architectural consistency.

Final merge authority for the official repository is reserved to `matteodurso88` and `dev-oriqo`.

Contributor credit is preserved through Git and pull-request history and, where appropriate, project acknowledgements.

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
5. which EN/IT documentation files were updated;
6. any compatibility or security impact;
7. whether the contributor expects maintainers to adapt or restructure the proposed implementation.

A PR may be accepted conceptually while its implementation is still changed by maintainers before final integration.

### Documentation parity

English and Italian documentation are peers. Neither language is considered secondary. If a translated document cannot be updated in the same change, the PR should not be considered complete.

---

## Italiano

Grazie per voler contribuire a Bashloom.

Bashloom è un progetto open source italiano con un modello di contribuzione internazionale. Il repository è di proprietà di Matteo D'Urso (`matteodurso88`); le attività tecniche quotidiane possono essere svolte tramite l'account tecnico Developer Oriqo (`dev-oriqo`). `GOVERNANCE.md` contiene le regole di governance ufficiali del progetto.

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

### Licenza dei contributi

Bashloom è rilasciato sotto licenza MIT.

Inviando un contributo, accetti che tale contributo possa essere distribuito sotto la stessa licenza MIT del progetto. Mantieni il copyright sul tuo contributo originale salvo diverso accordo scritto esplicito.

Al momento non è richiesto alcun Contributor License Agreement (CLA).

### Revisione finale dei maintainer

I contributi esterni sono proposte di integrazione nella codebase ufficiale di Bashloom. L'apertura di una pull request non crea alcun diritto al merge.

Ogni contributo esterno richiede revisione finale da parte dei maintainer. I maintainer possono richiedere modifiche, rifiutare, suddividere, fare squash, rifattorizzare, adattare, riscrivere o reimplementare un contributo prima dell'integrazione. Possono inoltre modificare naming, forma delle API, test o documentazione per preservare sicurezza, portabilità, manutenibilità e coerenza architetturale.

L'autorità di merge finale sul repository ufficiale è riservata a `matteodurso88` e `dev-oriqo`.

Il credito ai contributor viene preservato tramite cronologia Git e delle pull request e, quando opportuno, tramite riconoscimenti nel progetto.

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
5. quali file di documentazione EN/IT sono stati aggiornati;
6. eventuali impatti di compatibilità o sicurezza;
7. se il contributor prevede che i maintainer adattino o ristrutturino l'implementazione proposta.

Una PR può essere accettata concettualmente anche se la sua implementazione viene successivamente modificata dai maintainer prima dell'integrazione finale.

### Parità documentale

La documentazione inglese e italiana ha pari dignità. Nessuna delle due lingue è considerata secondaria. Se non è possibile aggiornare entrambe nella stessa modifica, la PR non dovrebbe essere considerata completa.
