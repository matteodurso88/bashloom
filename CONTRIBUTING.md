# Contributing to Bashloom / Contribuire a Bashloom

## English

Thank you for considering a contribution to Bashloom.

Bashloom is an Italian open-source project with an international contribution model. The repository is owned by Matteo D'Urso (`matteodurso88`); day-to-day technical work may be performed by the technical account Developer Oriqo (`dev-oriqo`). See `GOVERNANCE.md` for the authoritative project governance rules.

### Contribution rules

- Source code identifiers and public API names must be in **English**.
- The merged codebase uses **English code comments**.
- Contributors may write draft code comments, documentation, explanations and review notes in **their native language**.
- The canonical user-facing documentation is maintained in **English and Italian**.
- Maintainers are responsible for adapting accepted contributions into canonical EN/IT documentation and for converting merged code comments to English.
- A contribution must not be rejected solely because the contributor does not know English or Italian.
- Optional contributor-language documentation may be retained as a reviewed **community translation** under `docs/translations/<locale>/`.
- Community translations are supplementary, non-canonical and may lag behind the EN/IT canonical documentation.
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

Every external contribution requires final maintainer review. Maintainers may request changes, reject, split, squash, refactor, adapt, rewrite or reimplement a proposed contribution before integration. They may also change naming, API shape, tests, comments or documentation to preserve security, portability, maintainability and architectural consistency.

Final merge authority for the official repository is reserved to `matteodurso88` and `dev-oriqo`.

Contributor credit is preserved through Git and pull-request history and, where appropriate, project acknowledgements.

### Language accessibility

You may contribute even if you do not know English or Italian.

You may submit:

- documentation in your native language;
- PR explanations and review notes in your native language;
- draft source comments in your native language.

Before merge, maintainers will adapt the accepted material into the project's canonical forms:

- documentation: **EN + IT**;
- merged source comments: **English**;
- identifiers and API names: **English**.

When useful, the contributor's language version may be preserved and reviewed as an optional community translation so the contributor can read the maintainer-adapted result in a language they understand.

### Before opening a pull request

Run, when available:

```bash
bash -n src/bashloom.sh
shellcheck src/**/*.sh tests/**/*.bash
shfmt -d .
bats tests
```

### Pull requests

A pull request should explain, in any language the contributor is comfortable using:

1. what problem it solves;
2. why the change belongs in Bashloom;
3. whether public behavior changes;
4. which tests were added or updated;
5. which documentation language(s) were provided;
6. whether maintainer translation/adaptation is required;
7. any compatibility or security impact;
8. whether the contributor would like their native-language documentation to be retained as a community translation.

A PR may be accepted conceptually while its implementation is still changed by maintainers before final integration.

### Documentation parity

English and Italian are the two canonical documentation languages and have equal status. Contributors may work in another language; maintainers are responsible for ensuring the canonical EN/IT counterparts are present and semantically aligned before merge.

See `docs/DOCUMENTATION_POLICY.md` for the authoritative documentation-language policy.

---

## Italiano

Grazie per voler contribuire a Bashloom.

Bashloom è un progetto open source italiano con un modello di contribuzione internazionale. Il repository è di proprietà di Matteo D'Urso (`matteodurso88`); le attività tecniche quotidiane possono essere svolte tramite l'account tecnico Developer Oriqo (`dev-oriqo`). `GOVERNANCE.md` contiene le regole di governance ufficiali del progetto.

### Regole di contribuzione

- Identificatori nei sorgenti e nomi delle API pubbliche devono essere in **inglese**.
- La codebase integrata utilizza **commenti nei sorgenti in inglese**.
- I contributor possono scrivere commenti provvisori nel codice, documentazione, spiegazioni e note di revisione nella **propria lingua madre**.
- La documentazione canonica destinata agli utenti viene mantenuta in **inglese e italiano**.
- I maintainer sono responsabili di adattare i contributi accettati nella documentazione canonica EN/IT e di convertire in inglese i commenti del codice prima del merge.
- Un contributo non deve essere rifiutato esclusivamente perché il contributor non conosce l'inglese o l'italiano.
- La documentazione nella lingua del contributor può essere conservata opzionalmente come **traduzione della community** revisionata sotto `docs/translations/<locale>/`.
- Le traduzioni della community sono supplementari, non canoniche e possono non essere sempre allineate alla documentazione canonica EN/IT.
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

Ogni contributo esterno richiede revisione finale da parte dei maintainer. I maintainer possono richiedere modifiche, rifiutare, suddividere, fare squash, rifattorizzare, adattare, riscrivere o reimplementare un contributo prima dell'integrazione. Possono inoltre modificare naming, forma delle API, test, commenti o documentazione per preservare sicurezza, portabilità, manutenibilità e coerenza architetturale.

L'autorità di merge finale sul repository ufficiale è riservata a `matteodurso88` e `dev-oriqo`.

Il credito ai contributor viene preservato tramite cronologia Git e delle pull request e, quando opportuno, tramite riconoscimenti nel progetto.

### Accessibilità linguistica

È possibile contribuire anche senza conoscere inglese o italiano.

È possibile inviare:

- documentazione nella propria lingua madre;
- spiegazioni della PR e note di revisione nella propria lingua madre;
- commenti provvisori nei sorgenti nella propria lingua madre.

Prima del merge, i maintainer adatteranno il materiale accettato nelle forme canoniche del progetto:

- documentazione: **EN + IT**;
- commenti nei sorgenti integrati: **inglese**;
- identificatori e nomi API: **inglese**.

Quando utile, la versione nella lingua del contributor può essere conservata e revisionata come traduzione opzionale della community, così che il contributor possa leggere il risultato adattato dai maintainer in una lingua che comprende.

### Prima di aprire una pull request

Eseguire, quando disponibili:

```bash
bash -n src/bashloom.sh
shellcheck src/**/*.sh tests/**/*.bash
shfmt -d .
bats tests
```

### Pull request

Una pull request dovrebbe spiegare, in qualunque lingua il contributor sia a proprio agio nell'utilizzare:

1. quale problema risolve;
2. perché la modifica appartiene a Bashloom;
3. se cambia il comportamento pubblico;
4. quali test sono stati aggiunti o aggiornati;
5. quale/i lingua/e della documentazione sono state fornite;
6. se è necessaria la traduzione/l'adattamento da parte dei maintainer;
7. eventuali impatti di compatibilità o sicurezza;
8. se il contributor desidera che la documentazione nella propria lingua sia conservata come traduzione della community.

Una PR può essere accettata concettualmente anche se la sua implementazione viene successivamente modificata dai maintainer prima dell'integrazione finale.

### Parità documentale

Inglese e italiano sono le due lingue documentali canoniche e hanno pari dignità. I contributor possono lavorare in un'altra lingua; i maintainer sono responsabili di assicurare che le controparti canoniche EN/IT siano presenti e semanticamente allineate prima del merge.

Vedi `docs/DOCUMENTATION_POLICY.md` per la policy linguistica documentale ufficiale.
