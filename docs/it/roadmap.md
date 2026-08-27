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

- [x] modello esplicito di installazione sotto prefix
- [x] helper e guida al vendoring
- [x] caricamento selettivo dei moduli con dipendenze dichiarate
- [x] documentazione compatibilità
- [x] release gate sui metadata di versione
- [x] workflow di release su tag con archivio e checksum SHA-256
- [x] copertura contrattuale Bats dei percorsi di consumo
- [x] esempio M5 mantenuto
- [x] documentazione consumption EN/IT

### M6A — Hardening Linux & Idempotenza

- [x] change tracking aggregato e per ultima operazione
- [x] semantica changed/no-op per directory idempotenti
- [x] semantica changed/no-op per symlink idempotenti
- [x] `blm_ensure_mode`
- [x] `blm_ensure_line`
- [x] controlli espliciti delle dipendenze `readlink` e `rm` dove necessarie
- [x] copertura contrattuale Bats per l'idempotenza
- [x] esempio idempotenza mantenuto e copertura full-tour
- [x] documentazione idempotenza EN/IT
- [ ] hardening process-group per `blm_timeout`

Le matrici cross-distribution, macOS e WSL sono rimandate finché quegli ambienti non potranno essere validati direttamente.

### M6B — Output & Error Model

- [x] diagnostica runtime/versione
- [x] helper title/section
- [x] helper di failure espliciti senza exit impliciti
- [x] comportamento di presentazione deterministico human/plain/JSON
- [x] contratti stdout/stderr e machine-readable documentati
- [x] copertura contrattuale Bats per M6B
- [x] esempio M6B mantenuto e copertura full-tour
- [x] documentazione output/error EN/IT
- [ ] contesto errore strutturato più ricco
- [ ] hardening policy colore e Unicode

### M6C — Primitive System avanzate

- [x] helper backup sicuro esplicito
- [x] helper safe copy/move senza sovrascrittura
- [x] helper checksum SHA-256
- [x] locking atomico tramite directory e `blm_with_lock`
- [x] helper di convergenza ownership
- [x] helper path XDG config/data/cache/state/runtime
- [x] copertura contrattuale Bats per M6C
- [x] esempio M6C mantenuto e copertura full-tour
- [x] documentazione advanced-system EN/IT

### M6D — Integrations

Prossimo blocco di implementazione. Primi adapter candidati:

- [ ] Git
- [ ] systemd
- [ ] Docker / Compose
- [ ] Debian / APT
- [ ] network checks

### M6E — Terminal UX

Scope candidato:

- [ ] spinner/progress
- [ ] confirm/input/password/select
- [ ] pannelli/tabelle/tree rendering
- [ ] degradazione controllata in ambienti non interattivi

### M6F — Production Validation

Prima della `v0.1.0`:

- [ ] integrare primitive Bashloom in almeno un workflow reale di deployment
- [ ] validare su un workflow desktop/installer
- [ ] validare su un workflow system/provisioning
- [ ] correggere API instabili sulla base del feedback reale
- [ ] taggare la prima `v0.1.0` utilizzabile

### Qualità

- [x] ShellCheck clean per il sorgente pubblico implementato
- [x] shfmt clean per il sorgente pubblico implementato
- [x] test Bats per le API pubbliche implementate
- [x] esempi eseguibili mantenuti fino a M6C
- [ ] matrice versioni Bash
- [ ] matrice cross-distribution
- [ ] controllo parità documentale dove praticabile

## v0.2 — Terminal UX

Scope candidato dopo la prima release foundation utilizzabile:

- pannelli e tabelle più ricchi
- tree rendering
- spinner/progress avanzati
- timer
- flussi prompt/select più ricchi
- backend avanzati opzionali come Gum/fzf

## v0.3 — System & Integrations

Scope candidato dopo la stabilizzazione della foundation v0.1:

- adapter Git esteso
- adapter Docker esteso
- adapter systemd esteso
- helper Debian/APT
- helper XDG
- controlli di rete

## Esplorazioni successive

- rifiniture output human/plain/JSON
- bundler di moduli vendorabile
- reference API generata
- shell completion per una futura CLI Bashloom

Nessun elemento successivo alla v0.1 è considerato impegnativo fino a quando non viene specificato nella documentazione e, quando opportuno, tramite ADR.
