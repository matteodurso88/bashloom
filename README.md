# Bashloom

**Weave better shell scripts.**

> A modular, dependency-free Bash runtime for reliable shell applications, terminal UX and system automation.
>
> Una runtime Bash modulare e senza dipendenze obbligatorie per applicazioni shell affidabili, UX da terminale e automazione di sistema.

**Current public baseline / Baseline pubblica attuale:** [`v0.1.0-rc1`](https://github.com/matteodurso88/bashloom/releases/tag/v0.1.0-rc1) · release candidate for multi-consumer validation / release candidate per validazione multi-consumer.

Bashloom is an **Italian open-source project** created and owned by **Matteo D'Urso** (`matteodurso88`) and developed operationally with the technical account **Developer Oriqo** (`dev-oriqo`). It is part of the engineering work presented through **[matt88.it](https://matt88.it)**.

Bashloom è un **progetto open source italiano** creato e di proprietà di **Matteo D'Urso** (`matteodurso88`) e sviluppato operativamente tramite l'account tecnico **Developer Oriqo** (`dev-oriqo`). Fa parte delle attività di engineering presentate attraverso **[matt88.it](https://matt88.it)**.

## Use Bashloom / Usa Bashloom

For repository-level integration, Bashloom recommends a **pinned vendored runtime** with integrity metadata, one project-local adapter, and the same validation scripts in local CI and GitHub Actions.

Per l'integrazione a livello repository, Bashloom raccomanda un **runtime vendorizzato e pinnato** con metadata di integrità, un unico adapter locale al progetto e gli stessi script di validazione in CI locale e GitHub Actions.

- Consumer contract: [`docs/en/consumer-contract.md`](docs/en/consumer-contract.md) · [`docs/it/consumer-contract.md`](docs/it/consumer-contract.md)
- Consumption model: [`docs/en/consumption.md`](docs/en/consumption.md) · [`docs/it/consumption.md`](docs/it/consumption.md)
- Release candidate: [`v0.1.0-rc1`](https://github.com/matteodurso88/bashloom/releases/tag/v0.1.0-rc1)

## What Bashloom provides / Cosa offre Bashloom

Bashloom is not a collection of decorative `echo` helpers. It is a small runtime layer for serious Bash programs and operational scripts.

Bashloom non è una raccolta di helper decorativi per `echo`: è un piccolo layer runtime per programmi Bash e script operativi affidabili.

- **Terminal UX / UX da terminale** — status messages, sections, panels, tables, prompts, progress, spinners and graceful non-TTY degradation.
- **Reliability / Affidabilità** — exact exit-status preservation, retry, wait, timeout, cleanup, traps, rollback and transaction-oriented workflows.
- **Preflight & validation / Preflight e validazione** — commands, files, directories, permissions, environment and capabilities.
- **Filesystem & idempotency / Filesystem e idempotenza** — atomic replacement, locking, checksums, path/XDG helpers and change tracking.
- **Output & state / Output e stato** — human/plain/JSON output, logging, diagnostics, configuration and persistent state.
- **Integrations / Integrazioni** — optional Git, Docker Compose, systemd, network and APT helpers without making them mandatory core dependencies.
- **TUI foundations / Fondamenta TUI** — themes, visual variants, width-aware Unicode rendering, deterministic ASCII/CI fallbacks and dependency-light full-screen primitives.

## Engineering principles / Principi ingegneristici

1. **Dependency-free core / Core senza dipendenze obbligatorie.** Bash itself is the only mandatory runtime dependency.
2. **Source-safe behavior / Comportamento source-safe.** Sourcing Bashloom must not silently change the caller's shell options, traps or global environment.
3. **Graceful degradation / Degradazione corretta.** TTY, CI, pipes, `TERM=dumb`, `NO_COLOR` and limited-Unicode environments remain usable.
4. **Operational correctness first / Correttezza operativa prima dell'estetica.** Presentation must never hide failures or alter exit semantics.
5. **Small public API / API pubblica contenuta.** Prefer focused, tested primitives over large collections of loosely related helpers.
6. **Documentation is part of the feature / La documentazione è parte della feature.** Public behavior and API changes require synchronized EN/IT documentation.

Public namespace convention / Convenzione namespace pubblici:

```bash
blm_*      # public API
_blm_*     # internal API
BLM_*      # public configuration/environment
_BLM_*     # internal state
```

## Release status / Stato release

`v0.1.0-rc1` is the first public release-candidate baseline for Bashloom `v0.1.0`, frozen for multi-consumer field validation.

`v0.1.0-rc1` è la prima baseline release candidate pubblica di Bashloom `v0.1.0`, congelata per la validazione sul campo multi-consumer.

The RC release pipeline passed Bash syntax checks, ShellCheck, shfmt, source-documentation contracts, EN/IT public-API documentation parity gates, Bats tests and maintained examples/full-tour validation.

La pipeline RC ha superato controlli di sintassi Bash, ShellCheck, shfmt, contratti di documentazione sorgente, gate di parità EN/IT delle API pubbliche, test Bats ed esempi mantenuti/full-tour.

See / Vedi: [`Bashloom 0.1.0-rc1`](https://github.com/matteodurso88/bashloom/releases/tag/v0.1.0-rc1).

## Contributing / Contribuire

Bashloom has a public contributor roadmap with scoped work designed not to destabilize the current RC validation baseline.

Bashloom dispone di una roadmap pubblica per contributor con attività circoscritte progettate per non destabilizzare la baseline RC in validazione.

- **Contributor roadmap / Roadmap contributor:** [Issue #28](https://github.com/matteodurso88/bashloom/issues/28)
- **Recommended first contribution / Primo contributo consigliato:** [Issue #31](https://github.com/matteodurso88/bashloom/issues/31)
- **Help wanted:** [#29](https://github.com/matteodurso88/bashloom/issues/29), [#30](https://github.com/matteodurso88/bashloom/issues/30), [#32](https://github.com/matteodurso88/bashloom/issues/32), [#33](https://github.com/matteodurso88/bashloom/issues/33)
- **Contribution rules / Regole di contribuzione:** [`CONTRIBUTING.md`](CONTRIBUTING.md)
- **Governance:** [`GOVERNANCE.md`](GOVERNANCE.md)

External contributions are welcome. Public API or behavior changes should be discussed before implementation and require final maintainer review.

I contributi esterni sono benvenuti. Le modifiche ad API pubbliche o comportamento devono essere discusse prima dell'implementazione e richiedono revisione finale dei maintainer.

## Documentation / Documentazione

User-facing project documentation is maintained in **English and Italian**. Source code, identifiers, commit messages and code comments use **English**.

La documentazione utente del progetto viene mantenuta in **inglese e italiano**. Sorgenti, identificatori, commit message e commenti nel codice utilizzano **inglese**.

See / Vedi: [`docs/DOCUMENTATION_POLICY.md`](docs/DOCUMENTATION_POLICY.md).

## Ownership & credits / Proprietà e crediti

- **Creator & owner / Creatore e proprietario:** Matteo D'Urso — [`matteodurso88`](https://github.com/matteodurso88)
- **Technical development account / Account tecnico di sviluppo:** Developer Oriqo — `dev-oriqo`
- **Professional showcase / Presentazione professionale:** [matt88.it](https://matt88.it)
- **Origin / Origine:** Italy / Italia 🇮🇹

`dev-oriqo` is a technical GitHub account used by Matteo D'Urso for development operations, commits, pull requests, issues and repository maintenance. It is not a separate project owner.

`dev-oriqo` è un account GitHub tecnico utilizzato da Matteo D'Urso per operazioni di sviluppo, commit, pull request, issue e manutenzione del repository. Non rappresenta un proprietario separato del progetto.

## License / Licenza

Bashloom is released under the **MIT License**.

Bashloom è distribuito con licenza **MIT**.
