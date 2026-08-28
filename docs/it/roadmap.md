# Roadmap

Bashloom è nella fase di validazione release candidate della v0.1. La roadmap è volutamente guidata dalle capability e non da date prefissate.

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
- [x] hardening process-group per comandi esterni in `blm_timeout` tramite GNU `timeout` quando disponibile

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
- [x] adapter Debian / APT opzionale

L'integrazione APT fa parte di `v0.1.0-rc1`. Usa `apt-get`, `dpkg-query` e `apt-cache`, verifica le dipendenze feature-specific a call-time, non invoca mai sudo implicitamente e non aggiorna mai gli indici pacchetti in modo nascosto.

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
- [x] rendering tree topology-aware
- [x] `BLM_UI_CHARSET=auto|ascii|unicode`
- [x] registry theme/style e varianti multiple per componente
- [x] layout terminale width-aware con fallback deterministico
- [x] foundation TUI full-screen dependency-light
- [x] mantenimento fallback CI-safe
- [x] documentazione EN/IT e copertura Bats

Backend Gum/fzf obbligatori e ulteriore espansione cosmetica/stilistica restano candidati post-v0.1.

### M6F — Production Validation

Prima della `v0.1.0`:

- [x] definire protocollo di ownership e field validation
- [x] registrare Oriqo Infrastructure come consumer per il deployment
- [x] richiedere che bug e miglioramenti emersi nei consumer vengano riportati upstream su Bashloom
- [x] completare almeno una validazione reale di deployment tramite il workflow del consumer owner — staging Oriqo Infrastructure PASS
- [ ] validare un workflow desktop/installer
- [ ] validare un workflow system/provisioning
- [ ] rivedere le API instabili sulla base del feedback reale quando l'evidence lo richiede
- [x] pubblicare `v0.1.0-rc1` come baseline comune per la validazione multi-consumer
- [ ] completare la campagna di validazione multi-consumer della RC
- [ ] taggare la prima `v0.1.0` stabile

L'evidence storica di deployment M6F su Oriqo ha usato il pin `b6a096ba1feb31f41a639856b29ae07e25ba3676` ed è terminata con successo. Il target corrente per l'adozione repository-wide nei consumer è `v0.1.0-rc1` al commit `bbbbd9b8e61c7d951b8b9fc8f00c351b50a1bf51`.

Vedi `docs/it/production-validation.md` per il protocollo canonico M6F e lo stato corrente dell'evidence.

### Qualità

- [x] ShellCheck clean
- [x] shfmt clean
- [x] test Bats per le API implementate
- [x] esempi mantenuti sull'intera superficie feature della RC
- [x] documentazione API pubblica in-source verificata dalla CI
- [x] parità documentale EN/IT delle API pubbliche verificata automaticamente
- [ ] matrice versioni Bash
- [ ] matrice cross-distribution

## Roadmap contributor post-v0.1

Il lavoro feature post-RC è tracciato separatamente dalla stabilizzazione della RC. Vedi la issue GitHub `#28` per la roadmap contributor pubblica e i workstream scoped, inclusi identità/color system terminale più ricchi, componenti presentation evoluti, esempi/cookbook, portabilità/integrazioni e outreach.

## Esplorazioni successive

- contesto errore strutturato più ricco
- matrici di portabilità più ampie
- integrazioni aggiuntive guidate da evidence reale dei consumer
- backend Terminal UX opzionali quando giustificati
- shell completion per futura CLI Bashloom

Nessun elemento post-v0.1 è considerato impegnativo finché non viene specificato nella documentazione e, quando opportuno, tramite ADR o issue scoped.