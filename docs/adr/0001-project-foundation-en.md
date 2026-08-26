# ADR 0001 — Project foundation

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

Bashloom is being created as a public reusable Bash library rather than an internal helper collection. The project must support international contributors while preserving and explicitly communicating its Italian origin. It must also remain usable in constrained Linux/server environments where installing auxiliary binaries is undesirable.

## Decision

1. Bashloom is an **Italian open-source project** created and owned by Matteo D'Urso (`matteodurso88`).
2. Developer Oriqo (`dev-oriqo`) is the owner's **technical development account** and may perform commits, pull requests, issue maintenance and other repository operations. It is not a separate owner.
3. **matt88.it** is credited as the project showcase and owner contact surface.
4. User-facing project documentation is maintained with **English/Italian parity**.
5. Source code, identifiers, comments, commit messages and pull-request titles use **English**.
6. The mandatory runtime dependency of the core is **Bash only**.
7. Sourcing Bashloom must be **source-safe**: no implicit strict mode, trap replacement, `IFS` mutation or unrelated caller-state mutation.
8. Public API uses `blm_*`; internal API uses `_blm_*`.
9. Bashloom initially targets Bash >= 4.3 with Linux as first-class platform.

## Consequences

- Documentation work is part of feature completion.
- Contributors can work in one technical language inside source files while Italian users receive first-class documentation.
- Optional tools such as Gum, fzf or jq may enhance modules but cannot become hidden core requirements.
- API growth must remain deliberate because the project is intended for public reuse.

## Alternatives considered

### Bilingual source comments

Rejected because duplicated comments would increase code noise and synchronization cost without improving international contribution.

### POSIX sh compatibility as a primary target

Rejected for the initial architecture because it would significantly constrain implementation while Bash is an explicit project premise.

### Gum or another external binary as a mandatory runtime

Rejected because it would prevent Bashloom from serving minimal servers, containers, rescue systems and SBC environments without extra installation steps.
