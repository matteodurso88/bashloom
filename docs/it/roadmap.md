# Roadmap

Bashloom è attualmente nella fase foundation / implementazione iniziale della v0.1. La roadmap è volutamente guidata dalle capability e non da date prefissate.

## pre-v0.1 — Foundation

- [x] identità del progetto e modello di ownership
- [x] policy documentale EN/IT
- [x] baseline architetturale
- [x] runtime entrypoint source-safe
- [x] metadata di versione
- [x] rilevamento capability di base
- [x] output di stato di base
- [x] requirement check di base
- [x] smoke test Bats
- [x] CI con ShellCheck/shfmt/Bats
- [x] template contributor per issue e pull request
- [x] bozza specifica API delle primitive v0.1
- [ ] matrice di test compatibilità

## v0.1 — Reliable Shell Foundation

### M1 — Command Runtime

- [x] `blm_run`
- [x] preservazione esatta dell'exit status
- [x] compatibilità con `set -e` del caller
- [x] `--dry-run` locale
- [x] `BLM_DRY_RUN=1` globale
- [x] `blm_step`
- [x] nessun `eval` / esecuzione argv-safe

### M2 — Reliability

- [x] `blm_retry`
- [x] delay retry e backoff intero
- [x] `blm_wait_for`
- [x] status timeout `124`
- [x] `blm_timeout`
- [x] cleanup stack LIFO
- [x] installazione esplicita delle cleanup trap
- [x] rifiuto di sovrascrivere trap del caller
- [x] rollback stack LIFO
- [x] transazioni esplicite begin/commit/rollback
- [x] copertura Bats dei contratti M1/M2
- [x] documentazione runtime/reliability EN/IT

### M3 — System Safety

- [x] require root
- [x] controlli permessi readable/writable/executable
- [x] helper sicuri per file/directory temporanei
- [x] ensure directory
- [x] ensure symlink
- [x] scrittura atomica file
- [x] helper path lessicali pure-Bash
- [x] risoluzione path dell'entrypoint senza dipendenze esterne
- [x] copertura contrattuale Bats per M3
- [x] documentazione system-safety EN/IT

### M4 — Runtime State

- [x] fondamenta logging
- [x] helper environment
- [x] helper di configurazione key/value sicuri
- [x] state file atomici
- [x] modello output human/plain/JSON
- [x] output key/value machine-readable
- [x] copertura contrattuale Bats per M4
- [x] esempio M4 mantenuto e copertura full-tour
- [x] documentazione runtime-state EN/IT

### M5 — Consumption

Prossimo blocco di implementazione:

- [ ] modello di installazione
- [ ] guida al vendoring
- [ ] caricamento selettivo moduli
- [ ] documentazione compatibilità
- [ ] workflow versioning/release

### M6 — Production Validation

- [ ] integrare primitive Bashloom in almeno un workflow reale di deployment
- [ ] validare su un workflow desktop/installer
- [ ] validare su un workflow system/provisioning
- [ ] correggere API instabili sulla base del feedback reale
- [ ] taggare la prima `v0.1.0` utilizzabile

### Lavori UI/Core v0.1 ancora da completare

- [ ] modello capability terminale più completo
- [x] modello modalità di output
- [ ] hardening policy colore e Unicode
- [ ] diagnostica runtime/versione
- [ ] helper title/section
- [x] output key/value
- [ ] helper espliciti error/exit

### Qualità

- [x] ShellCheck clean per il sorgente pubblico implementato
- [x] shfmt clean per il sorgente pubblico implementato
- [x] test Bats per le API pubbliche implementate
- [x] esempi eseguibili mantenuti fino a M4
- [ ] matrice versioni Bash
- [ ] matrice cross-distribution
- [ ] controllo parità documentale dove praticabile

## v0.2 — Terminal UX

Scope candidato:

- pannelli
- tabelle
- tree rendering
- spinner
- progress
- timer
- confirm/input/password/select
- backend avanzati opzionali come Gum/fzf

## v0.3 — System & Integrations

Scope candidato:

- adapter Git
- adapter Docker
- adapter systemd
- helper Debian/APT
- helper XDG
- controlli di rete

## Esplorazioni successive

- rifiniture output human/plain/JSON
- bundler di moduli vendorabile
- reference API generata
- shell completion per una futura CLI Bashloom

Nessun elemento successivo alla v0.1 è considerato impegnativo fino a quando non viene specificato nella documentazione e, quando opportuno, tramite ADR.
