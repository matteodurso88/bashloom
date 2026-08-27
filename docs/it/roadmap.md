# Roadmap

Bashloom è attualmente nella fase foundation / implementazione iniziale della v0.1. La roadmap è volutamente guidata dalle capability e non da date prefissate.

## pre-v0.1 — Foundation

- [x] identità del progetto e modello di ownership
- [x] policy documentale EN/IT
- [x] baseline architetturale
- [x] runtime entrypoint source-safe
- [x] metadata di versione
- [x] capability/status/requirement di base
- [x] smoke test Bats
- [x] CI ShellCheck/shfmt/Bats
- [x] template contributor
- [x] bozza API v0.1
- [ ] matrice di test compatibilità

## v0.1 — Reliable Shell Foundation

### M1 — Command Runtime

- [x] `blm_run`, exit status esatto, dry-run e `blm_step`
- [x] compatibilità con `set -e`
- [x] nessun `eval` / esecuzione argv-safe

### M2 — Reliability

- [x] retry/wait/timeout
- [x] cleanup/rollback LIFO e transazioni esplicite
- [x] test Bats e documentazione EN/IT

### M3 — System Safety

- [x] requirement root/permessi
- [x] risorse temp sicure
- [x] convergenza directory/symlink e atomic write
- [x] helper path lessicali
- [x] test e documentazione EN/IT

### M4 — Runtime State

- [x] logging/helper environment
- [x] config letterale sicura e stato atomico
- [x] output human/plain/JSON
- [x] test/esempio/docs

### M5 — Consumption

- [x] installer/vendoring
- [x] loader selettivo
- [x] documentazione compatibilità e release gate/workflow
- [x] test ed esempio mantenuto

### M6A — Hardening Linux & Idempotenza

- [x] change tracking aggregato/per operazione
- [x] semantica changed/no-op per directory/symlink
- [x] `blm_ensure_mode`, `blm_ensure_line`
- [x] dependency check filesystem espliciti
- [x] test/esempio/docs
- [ ] hardening process-group per `blm_timeout`

Le matrici cross-distribution, macOS e WSL restano rimandate finché quegli ambienti non potranno essere validati direttamente.

### M6B — Output & Error Model

- [x] diagnostica e helper title/section
- [x] failure helper espliciti senza exit impliciti
- [x] contratti human/plain/JSON deterministici
- [x] test/esempio/docs
- [ ] contesto errore strutturato più ricco

### M6C — Primitive System avanzate

- [x] backup/copy/move sicuri e SHA-256
- [x] locking directory / `blm_with_lock`
- [x] convergenza ownership e path XDG
- [x] test/esempio/docs

### M6D — Integrations

- [x] adapter Git
- [x] adapter systemd
- [x] adapter Docker / Compose
- [x] readiness DNS / HTTP
- [x] gruppi integrazione selettivi
- [x] standard documentazione in-source profonda e gate CI
- [x] hardening commenti repository-wide
- [ ] adapter Debian / APT

APT resta rimandato perché policy package-management e variabilità dell'ambiente sono significativamente più ampie rispetto agli adapter sottili già introdotti.

### M6E — Terminal UX Foundation

- [x] spinner/progress
- [x] confirm/input/password/select
- [x] panel/table/tree
- [x] degradazione non-interattiva deterministica
- [x] gruppo loader selettivo `terminal`
- [x] test/esempio/full-tour/docs

### M6E.1 — Rich Terminal Rendering

- [x] progress bar visuale a larghezza fissa
- [x] spinner Unicode/ASCII animato
- [x] panel rich auto-dimensionati
- [x] tabelle tab-delimited allineate
- [x] tree con branch marker
- [x] `BLM_UI_CHARSET=auto|ascii|unicode`
- [x] `BLM_UI_STYLE=rich|minimal`
- [x] `BLM_PROGRESS_WIDTH`
- [x] showcase interattiva dedicata `examples/11-rich-terminal.sh`
- [x] mantenimento fallback CI-safe
- [x] documentazione EN/IT e copertura Bats

Comportamenti TUI full-screen, mouse terminale e backend Gum/fzf obbligatori restano candidati post-v0.1.

### M6F — Production Validation

Prima della `v0.1.0`:

- [x] definire protocollo di ownership e field validation
- [x] registrare Oriqo Infrastructure come consumer candidato per il deployment
- [x] richiedere che bug e miglioramenti emersi nei consumer vengano riportati upstream su Bashloom
- [ ] completare almeno una validazione reale di deployment tramite il workflow del consumer owner
- [ ] validare un workflow desktop/installer
- [ ] validare un workflow system/provisioning
- [ ] rivedere le API instabili sulla base del feedback reale
- [ ] taggare la prima `v0.1.0` utilizzabile

Vedi `docs/it/production-validation.md` per il protocollo canonico M6F.

### Qualità

- [x] ShellCheck clean
- [x] shfmt clean
- [x] test Bats per le API implementate
- [x] esempi mantenuti fino a M6E.1
- [x] documentazione API pubblica in-source verificata dalla CI
- [ ] matrice versioni Bash
- [ ] matrice cross-distribution
- [ ] controllo parità documentale dove praticabile

## v0.2 — Terminal UX

Scope candidato dopo la prima release foundation utilizzabile: style registry, varianti spinner/progress, varianti panel/table/tree, temi/preset UI, override stile per chiamata, stili custom definiti dal consumer, timer, prompt/select più evoluti, backend opzionali Gum/fzf e componenti full-screen/cursor-addressed solo quando giustificati da consumer reali.

## v0.3 — System & Integrations

Scope candidato dopo la stabilizzazione v0.1: adapter Git/Docker/systemd più estesi, Debian/APT e network check più ricchi.

## Esplorazioni successive

- rifiniture human/plain/JSON
- bundler moduli vendorabile
- reference API generata
- shell completion per futura CLI Bashloom

Nessun elemento successivo alla v0.1 è considerato impegnativo finché non viene specificato nella documentazione e, quando opportuno, tramite ADR.
