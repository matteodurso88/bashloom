# Bashloom

**Weave better shell scripts.**

> A modular, dependency-free Bash runtime for reliable shell applications, terminal UX and system automation.
>
> Una runtime Bash modulare e senza dipendenze obbligatorie per applicazioni shell affidabili, UX da terminale e automazione di sistema.

Bashloom is an **Italian open-source project** created and owned by **Matteo D'Urso** (`matteodurso88`) and developed with the technical account **Developer Oriqo** (`dev-oriqo`). The project is also part of the technical work showcased on **matt88.it**.

Bashloom è un **progetto open source italiano** creato e di proprietà di **Matteo D'Urso** (`matteodurso88`) e sviluppato operativamente tramite l'account tecnico **Developer Oriqo** (`dev-oriqo`). Il progetto fa inoltre parte delle attività tecniche presentate su **matt88.it**.

## Use Bashloom in your project / Usa Bashloom nel tuo progetto

For repository-level integration, Bashloom recommends a **pinned vendored runtime** with integrity metadata, one project-local adapter, and the same validation scripts in local CI and GitHub Actions.

Per l'integrazione in un repository, Bashloom raccomanda un **runtime vendorizzato e pinnato** con metadata di integrità, un unico adapter locale al progetto e gli stessi script di validazione in CI locale e GitHub Actions.

- English: [`docs/en/consumer-contract.md`](docs/en/consumer-contract.md)
- Italiano: [`docs/it/consumer-contract.md`](docs/it/consumer-contract.md)
- Consumption model / Modello di utilizzo: [`docs/en/consumption.md`](docs/en/consumption.md) · [`docs/it/consumption.md`](docs/it/consumption.md)

## Want to contribute? / Vuoi contribuire?

Bashloom has a public contributor roadmap with scoped work that can be developed without destabilizing the `v0.1` RC validation baseline.

Bashloom dispone di una roadmap pubblica per i contributor con attività circoscritte che possono essere sviluppate senza destabilizzare la baseline di validazione RC `v0.1`.

- **Contributor roadmap / Roadmap contributor:** [Issue #28](https://github.com/matteodurso88/bashloom/issues/28)
- **Recommended first contribution / Primo contributo consigliato:** [Issue #31](https://github.com/matteodurso88/bashloom/issues/31)
- **Help wanted:** [#29](https://github.com/matteodurso88/bashloom/issues/29), [#30](https://github.com/matteodurso88/bashloom/issues/30), [#32](https://github.com/matteodurso88/bashloom/issues/32), [#33](https://github.com/matteodurso88/bashloom/issues/33)
- Contribution rules / Regole di contribuzione: [`CONTRIBUTING.md`](CONTRIBUTING.md)

Start from an existing scoped issue whenever possible. Public API or behavior changes should be discussed before implementation; accepted changes must preserve source-safety, exact status semantics, CI/non-TTY degradation and canonical EN/IT documentation parity.

Quando possibile, partire da una issue già circoscritta. Le modifiche ad API o comportamento pubblico vanno discusse prima dell'implementazione; i cambi accettati devono preservare source-safety, semantica esatta degli status, degradazione CI/non-TTY e parità documentale canonica EN/IT.

---

## English

### What Bashloom aims to be

Bashloom is not just a collection of colored `echo` helpers. Its goal is to provide a small, coherent runtime layer for serious Bash programs and operational scripts.

The project is designed around five areas:

- **Terminal UX** — status messages, sections, panels, tables, prompts, progress and graceful TTY degradation.
- **Reliability** — command execution, exit-code preservation, retry, wait, cleanup, traps and rollback-oriented workflows.
- **Preflight & validation** — commands, files, directories, permissions, environment, connectivity and capabilities.
- **System utilities** — filesystem, paths, XDG, permissions, temporary resources and platform detection.
- **Optional integrations** — Git, Docker, systemd, package managers and other tools without making them mandatory dependencies of the core.

### Core principles

1. **Dependency-free core.** Bash itself is the only mandatory runtime dependency.
2. **Source-safe behavior.** Sourcing Bashloom must not silently change the caller's shell options, traps or global environment.
3. **Graceful degradation.** TTY, CI, pipes, `TERM=dumb`, `NO_COLOR` and limited Unicode environments must remain usable.
4. **Small and stable public API.** Prefer a focused set of well-tested primitives over hundreds of loosely related helpers.
5. **Operational correctness first.** Pretty output must never hide command failures or alter exit semantics.
6. **Documentation is part of the feature.** A behavior or API change is incomplete until its EN/IT documentation is updated.
7. **Contribution-friendly code.** Source code and comments are written in English and should explain intent where the shell behavior is non-obvious.

### Project status

Bashloom is currently in **pre-v0.1 / foundation phase**. Public APIs are not stable yet.

Initial namespace convention:

```bash
blm_*      # public API
_blm_*     # internal API
BLM_*      # public configuration/environment
_BLM_*     # internal state
```

### Planned v0.1 scope

- terminal capability detection
- status output (`info`, `success`, `warn`, `error`)
- sections and steps
- command/file/directory/environment requirements
- command runner with exit-code preservation
- retry and wait primitives
- cleanup and trap helpers
- basic filesystem and path utilities
- logging foundations
- tests, ShellCheck and formatting CI

### Governance and contributions

External contributions are welcome, but they are proposals for inclusion in the official Bashloom codebase and require final maintainer review.

Maintainers may adapt, refactor or reimplement accepted contributions before merge to preserve API consistency, security, portability, maintainability, documentation quality and architectural coherence.

Final merge authority for the official repository is reserved to `matteodurso88` and `dev-oriqo`.

See `GOVERNANCE.md` for the authoritative governance policy and `CONTRIBUTING.md` for contribution requirements.

### Documentation languages

All user-facing project documentation is maintained in **English and Italian**. Source code, identifiers, commit messages and code comments use **English**.

See `docs/DOCUMENTATION_POLICY.md` for the synchronization policy.

---

## Italiano

### Cosa vuole essere Bashloom

Bashloom non è soltanto una raccolta di helper per colorare `echo`. L'obiettivo è fornire un piccolo layer runtime coerente per programmi Bash seri e script operativi.

Il progetto è costruito attorno a cinque aree:

- **UX da terminale** — messaggi di stato, sezioni, pannelli, tabelle, prompt, progress e degradazione corretta fuori da TTY.
- **Affidabilità** — esecuzione comandi, preservazione degli exit code, retry, wait, cleanup, trap e workflow orientati al rollback.
- **Preflight e validazione** — comandi, file, directory, permessi, ambiente, connettività e capability.
- **Utility di sistema** — filesystem, path, XDG, permessi, risorse temporanee e rilevamento piattaforma.
- **Integrazioni opzionali** — Git, Docker, systemd, package manager e altri strumenti senza renderli dipendenze obbligatorie del core.

### Principi fondamentali

1. **Core senza dipendenze obbligatorie.** Bash è l'unica dipendenza runtime richiesta.
2. **Comportamento source-safe.** Importare Bashloom non deve modificare silenziosamente shell option, trap o ambiente globale del chiamante.
3. **Degradazione corretta.** TTY, CI, pipe, `TERM=dumb`, `NO_COLOR` e ambienti Unicode limitati devono restare utilizzabili.
4. **API pubblica piccola e stabile.** Meglio poche primitive ben testate che centinaia di helper poco coerenti.
5. **Correttezza operativa prima dell'estetica.** L'output gradevole non deve mai nascondere errori o alterare gli exit code.
6. **La documentazione è parte della feature.** Una modifica a comportamento o API non è completa finché la documentazione EN/IT non è aggiornata.
7. **Codice contribuibile.** Sorgenti e commenti sono in inglese e devono spiegare l'intento quando il comportamento shell non è ovvio.

### Stato del progetto

Bashloom è attualmente in fase **pre-v0.1 / foundation**. Le API pubbliche non sono ancora stabili.

Convenzione iniziale dei namespace:

```bash
blm_*      # API pubblica
_blm_*     # API interna
BLM_*      # configurazione/environment pubblici
_BLM_*     # stato interno
```

### Scope previsto per v0.1

- rilevamento capability del terminale
- output di stato (`info`, `success`, `warn`, `error`)
- sezioni e step
- requisiti su comandi/file/directory/environment
- command runner con preservazione exit code
- primitive retry e wait
- helper cleanup e trap
- utility base filesystem e path
- fondamenta logging
- test, ShellCheck e CI di formattazione

### Governance e contributi

I contributi esterni sono benvenuti, ma costituiscono proposte di integrazione nella codebase ufficiale di Bashloom e richiedono revisione finale da parte dei maintainer.

I maintainer possono adattare, rifattorizzare o reimplementare i contributi accettati prima del merge per preservare coerenza delle API, sicurezza, portabilità, manutenibilità, qualità documentale e coerenza architetturale.

L'autorità di merge finale sul repository ufficiale è riservata a `matteodurso88` e `dev-oriqo`.

Vedi `GOVERNANCE.md` per la policy di governance ufficiale e `CONTRIBUTING.md` per i requisiti di contribuzione.

### Lingue della documentazione

Tutta la documentazione utente viene mantenuta in **inglese e italiano**. Sorgenti, identificatori, commit message e commenti nel codice sono in **inglese**.

Vedi `docs/DOCUMENTATION_POLICY.md` per la policy di sincronizzazione.

---

## Ownership & credits / Proprietà e crediti

- **Creator & owner / Creatore e proprietario:** Matteo D'Urso — `matteodurso88`
- **Technical development account / Account tecnico di sviluppo:** Developer Oriqo — `dev-oriqo`
- **Project showcase / Presentazione progetto:** matt88.it
- **Origin / Origine:** Italy / Italia 🇮🇹

`dev-oriqo` is a technical GitHub account used by Matteo D'Urso for development operations, commits, pull requests, issues and repository maintenance. It is not a separate project owner.

`dev-oriqo` è un account GitHub tecnico utilizzato da Matteo D'Urso per operazioni di sviluppo, commit, pull request, issue e manutenzione del repository. Non rappresenta un proprietario separato del progetto.

## License / Licenza

Bashloom is released under the **MIT License**.

Bashloom è distribuito con licenza **MIT**.
