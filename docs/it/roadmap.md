# Roadmap

Bashloom è attualmente nella fase foundation / implementazione iniziale della v0.1. La roadmap è volutamente guidata dalle capability e non da date prefissate.

## pre-v0.1 — Foundation

- [x] identità del progetto e modello di ownership
- [x] policy documentale EN/IT
- [x] baseline architetturale
- [x] runtime entrypoint source-safe
- [x] metadata di versione
- [x] capability/status/requirement di base
- [x] smoke test Bats e CI ShellCheck/shfmt/Bats
- [x] template contributor
- [x] bozza specifica API v0.1
- [ ] matrice di test compatibilità

## v0.1 — Reliable Shell Foundation

### M1 — Command Runtime

- [x] `blm_run`, dry-run e preservazione exit status
- [x] compatibilità con `set -e`
- [x] `blm_step`
- [x] nessun `eval` / esecuzione argv-safe

### M2 — Reliability

- [x] retry/wait/timeout
- [x] status timeout `124`
- [x] cleanup LIFO con trap esplicite
- [x] rollback LIFO e transazioni esplicite
- [x] test Bats e documentazione EN/IT

### M3 — System Safety

- [x] requirement root/permessi
- [x] risorse temporanee sicure
- [x] ensure directory/symlink
- [x] atomic write
- [x] helper path lessicali pure-Bash
- [x] test Bats e documentazione EN/IT

### M4 — Runtime State

- [x] logging e helper environment
- [x] configurazione letterale sicura
- [x] state file atomici
- [x] output human/plain/JSON
- [x] test, esempio mantenuto e documentazione EN/IT

### M5 — Consumption

- [x] installer prefix e vendoring
- [x] loader selettivo dependency-aware
- [x] documentazione compatibilità
- [x] release gate e workflow tag
- [x] test ed esempio mantenuto

### M6A — Hardening Linux & Idempotenza

- [x] change tracking aggregato/per operazione
- [x] semantica changed/no-op per directory/symlink
- [x] `blm_ensure_mode`
- [x] `blm_ensure_line`
- [x] dependency check filesystem espliciti
- [x] test, esempio e documentazione EN/IT
- [ ] hardening process-group per `blm_timeout`

Le matrici cross-distribution, macOS e WSL restano rimandate finché quegli ambienti non potranno essere validati direttamente.

### M6B — Output & Error Model

- [x] diagnostica runtime/versione
- [x] helper title/section
- [x] failure helper espliciti senza exit impliciti
- [x] output human/plain/JSON deterministico
- [x] contratti stdout/stderr documentati
- [x] test, esempio e documentazione EN/IT
- [ ] contesto errore strutturato più ricco
- [ ] hardening policy colore e Unicode

### M6C — Primitive System avanzate

- [x] backup e copy/move senza sovrascrittura
- [x] checksum SHA-256
- [x] locking atomico con `blm_with_lock`
- [x] convergenza ownership
- [x] helper XDG
- [x] test, esempio e documentazione EN/IT

### M6D — Integrations

- [x] adapter Git
- [x] adapter systemd
- [x] adapter Docker / Compose
- [x] readiness DNS / HTTP
- [x] gruppi loader selettivi per integrazioni
- [x] copertura contrattuale Bats
- [x] esempio M6D e full-tour
- [x] documentazione integrazioni EN/IT
- [x] standard profondo di documentazione in-source per API pubbliche
- [x] gate CI per la documentazione in-source
- [x] pass di hardening commenti su tutto il sorgente pubblico esistente
- [ ] adapter Debian / APT

APT resta fuori dalla prima tranche M6D perché policy di package management e variabilità di ambiente sono significativamente più ampie rispetto agli adapter sottili già introdotti.

### M6E — Terminal UX

- [x] spinner/progress
- [x] confirm/input/password/select
- [x] pannelli/tabelle/tree
- [x] degradazione controllata non-interattiva
- [x] gruppo loader selettivo `terminal`
- [x] copertura contrattuale Bats
- [x] esempio M6E e full-tour
- [x] documentazione Terminal UX EN/IT

Comportamenti TUI full-screen avanzati, backend esterni Gum/fzf e decorazioni Unicode più ricche restano candidati post-v0.1.

### M6F — Production Validation

Prima della `v0.1.0`:

- [ ] integrazione in almeno un deployment reale
- [ ] validazione desktop/installer
- [ ] validazione system/provisioning
- [ ] revisione API instabili da feedback reale
- [ ] tag `v0.1.0`

### Qualità

- [x] ShellCheck clean
- [x] shfmt clean
- [x] test Bats per API implementate
- [x] esempi mantenuti fino a M6E
- [x] documentazione API pubblica in-source verificata dalla CI
- [ ] matrice versioni Bash
- [ ] matrice cross-distribution
- [ ] controllo automatico parità documentale dove praticabile

## v0.2 — Terminal UX

Scope candidato dopo la prima release foundation utilizzabile: pannelli/tabelle più ricchi, spinner/progress avanzati, timer, prompt/select più evoluti, backend opzionali Gum/fzf e componenti full-screen solo se giustificati da consumer reali.

## v0.3 — System & Integrations

Scope candidato: adapter Git/Docker/systemd più estesi, Debian/APT e network checks più ricchi.

## Esplorazioni successive

- rifiniture output human/plain/JSON
- bundler moduli vendorabile
- reference API generata
- shell completion per futura CLI Bashloom

Nessun elemento successivo alla v0.1 è considerato impegnativo finché non viene specificato nella documentazione e, quando opportuno, tramite ADR.
