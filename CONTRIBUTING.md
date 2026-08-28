# Contributing to Bashloom / Contribuire a Bashloom

## English

Thank you for considering a contribution to Bashloom.

Bashloom is an Italian open-source project with an international contribution model. The repository is owned by Matteo D'Urso (`matteodurso88`); day-to-day technical work may be performed by the technical account Developer Oriqo (`dev-oriqo`). See `GOVERNANCE.md` for authoritative governance rules.

### Where to start

Start from the public contributor roadmap: https://github.com/matteodurso88/bashloom/issues/28

Recommended entry points:
- `#31` — task-oriented cookbook and classic Bash vs Bashloom examples (**good first issue**);
- `#29` — semantic color system and visual identity;
- `#30` — richer terminal components;
- `#32` — integrations and portability evidence;
- `#33` — community outreach and technical launch preparation.

Prefer an existing scoped issue before starting implementation. Discuss public API/behavior changes before coding. The `v0.1` RC validation baseline is governed separately by `#21`; contributor feature work must not silently change frozen RC semantics.

### Contribution rules

- Source identifiers and public API names are **English**.
- Merged source comments are **English**; contributors may draft comments/docs/review notes in their native language.
- Canonical user-facing documentation is maintained in **English and Italian**; maintainers adapt accepted contributions into both canonical languages.
- A contribution must not be rejected solely because the contributor does not know English or Italian.
- Optional community translations may live under `docs/translations/<locale>/`; they are supplementary and non-canonical.
- Public functions use `blm_*`; internal functions use `_blm_*`.
- New or materially changed public APIs require tests, canonical documentation where applicable, and **deep in-source documentation**.
- Every public `blm_*` function must have a nearby `# Public API: blm_name` marker. Its source docblock should explain purpose, usage, status/output semantics, side effects, external dependencies and relevant security/portability/invariant decisions. Do not merely restate syntax.
- Non-trivial internal `_blm_*` helpers should document assumptions and rationale even though they do not require the public marker.
- CI enforces the public source-documentation marker with `tools/check-source-docs.sh`.
- Avoid mandatory runtime dependencies in the source/core; feature-specific dependencies are checked only when the feature is invoked.
- Do not implicitly modify caller shell options, traps or global environment.
- Preserve command exit semantics; UI must never hide failures.
- Prefer small composable primitives over project-specific helpers.

See `docs/en/source-documentation.md` and `docs/it/source-documentation.md` for the complete source-comment standard.

### Licensing of contributions

Bashloom is licensed under the MIT License. By submitting a contribution, you agree that it may be distributed under the same MIT License. You retain copyright in your original contribution unless a different written agreement explicitly states otherwise. No CLA is currently required.

### Maintainer final review

External contributions are proposals for inclusion in the official codebase. Opening a pull request does not create a right to merge. Maintainers may request changes, reject, split, squash, refactor, adapt, rewrite or reimplement a proposal and may change naming, API shape, tests, comments or documentation to preserve security, portability, maintainability and architectural consistency.

Final merge authority is reserved to `matteodurso88` and `dev-oriqo`. Contributor credit is preserved through Git/PR history and, where appropriate, acknowledgements.

### Language accessibility

Contributors may submit documentation, PR explanations, review notes and draft source comments in their native language. Before merge, maintainers adapt accepted material to canonical EN+IT documentation, English merged source comments and English identifiers/API names. A contributor-language version may optionally be retained as a reviewed community translation.

### Before opening a pull request

Run, when available:

```bash
find src examples tools -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
find src examples tools -type f -name '*.sh' -print0 | xargs -0 shellcheck
shfmt -d -i 2 -ci src examples tools
bash tools/check-source-docs.sh
bats tests
bash examples/full-tour.sh
```

### Pull requests

A pull request should explain, in any language the contributor is comfortable using: the problem solved, why it belongs in Bashloom, public behavior changes, tests/docs updated, compatibility/security impact, and whether maintainer translation/adaptation is required.

### Documentation parity

English and Italian are the two canonical documentation languages and have equal status. Maintainers ensure canonical EN/IT counterparts are present and semantically aligned before merge. See `docs/DOCUMENTATION_POLICY.md`.

---

## Italiano

Grazie per voler contribuire a Bashloom.

Bashloom è un progetto open source italiano con modello di contribuzione internazionale. Il repository è di Matteo D'Urso (`matteodurso88`); le attività tecniche quotidiane possono essere svolte tramite l'account tecnico Developer Oriqo (`dev-oriqo`). `GOVERNANCE.md` contiene le regole ufficiali.

### Da dove iniziare

Parti dalla roadmap pubblica dei contributor: https://github.com/matteodurso88/bashloom/issues/28

Punti di ingresso consigliati:
- `#31` — cookbook task-oriented e confronti Bash classico vs Bashloom (**good first issue**);
- `#29` — sistema colori semantico e identità visiva;
- `#30` — componenti terminal rich più evoluti;
- `#32` — integrazioni ed evidence di portabilità;
- `#33` — outreach community e preparazione del lancio tecnico.

Preferire una issue già circoscritta prima di iniziare l'implementazione. Le modifiche ad API/comportamento pubblico vanno discusse prima di scrivere codice. La baseline RC `v0.1` è governata separatamente da `#21`; il lavoro contributor non deve modificare implicitamente semantiche RC congelate.

### Regole di contribuzione

- Identificatori e API pubbliche sono in **inglese**.
- I commenti integrati nei sorgenti sono in **inglese**; contributor possono preparare commenti/documenti/note nella propria lingua madre.
- La documentazione canonica user-facing è mantenuta in **inglese e italiano**; i maintainer adattano i contributi accettati in entrambe le lingue.
- Un contributo non viene rifiutato solo perché il contributor non conosce inglese o italiano.
- Traduzioni community opzionali possono vivere in `docs/translations/<locale>/` e restano supplementari/non canoniche.
- Funzioni pubbliche `blm_*`; funzioni interne `_blm_*`.
- API pubbliche nuove o modificate materialmente richiedono test, documentazione canonica quando applicabile e **documentazione in-source profonda**.
- Ogni funzione pubblica `blm_*` deve avere vicino il marker `# Public API: blm_name`. Il docblock deve spiegare scopo, uso, semantica status/output, side effect, dipendenze esterne e decisioni rilevanti di sicurezza/portabilità/invarianti. Non deve limitarsi a ripetere la sintassi.
- Gli helper interni `_blm_*` non banali devono comunque documentare assunzioni e motivazioni, pur senza marker pubblico obbligatorio.
- La CI applica il contratto tramite `tools/check-source-docs.sh`.
- Evitare dipendenze runtime obbligatorie nel source/core; dipendenze feature-specific solo a call-time.
- Non modificare implicitamente shell option, trap o ambiente globale del caller.
- Preservare gli exit status; la UI non deve nascondere failure.
- Preferire primitive piccole e componibili.

Vedi `docs/en/source-documentation.md` e `docs/it/source-documentation.md` per lo standard completo.

### Licenza e revisione finale

Bashloom usa licenza MIT; al momento non è richiesto CLA. I contributi esterni sono proposte e richiedono revisione finale dei maintainer. I maintainer possono modificare, suddividere, fare squash, rifattorizzare, adattare, riscrivere o reimplementare un contributo. L'autorità finale di merge è riservata a `matteodurso88` e `dev-oriqo`; il credito del contributor viene preservato nella storia Git/PR.

### Accessibilità linguistica

È possibile inviare documentazione, spiegazioni PR, note di revisione e commenti source provvisori nella propria lingua. Prima del merge, i maintainer adattano il materiale accettato in documentazione canonica EN+IT, commenti source inglesi e identificatori/API inglesi. Una versione nella lingua del contributor può essere conservata come traduzione community revisionata.

### Prima di aprire una pull request

```bash
find src examples tools -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
find src examples tools -type f -name '*.sh' -print0 | xargs -0 shellcheck
shfmt -d -i 2 -ci src examples tools
bash tools/check-source-docs.sh
bats tests
bash examples/full-tour.sh
```

### Pull request e parità documentale

Una PR dovrebbe spiegare problema, razionale, modifiche pubbliche, test/docs, impatto compatibilità/sicurezza e necessità di adattamento linguistico. Inglese e italiano hanno pari status come lingue canoniche; i maintainer garantiscono la parità semantica prima del merge. Vedi `docs/DOCUMENTATION_POLICY.md`.
