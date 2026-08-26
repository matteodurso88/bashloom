# Roadmap

Bashloom è attualmente nella fase di foundation. La roadmap è volutamente guidata dalle capability e non da date prefissate.

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
- [ ] template per issue e pull request
- [ ] specifica API delle primitive v0.1
- [ ] matrice di test compatibilità

## v0.1 — Reliable Shell Foundation

Capability pubbliche previste:

### Core

- modello capability terminale
- modello modalità di output
- policy colore e Unicode
- diagnostica runtime/versione

### UI

- info/success/warn/error
- title/section
- lifecycle degli step
- output key/value

### Ops

- require command/file/directory/environment
- command runner con preservazione esatta degli exit code
- retry
- wait-until con timeout e intervallo
- cleanup stack
- helper espliciti per error/exit

### System

- helper sicuri per file/directory temporanei
- ensure directory
- scrittura atomica file
- controllo permessi
- helper path

### Qualità

- ShellCheck clean
- shfmt clean
- test Bats per le API pubbliche
- matrice versioni Bash
- controllo parità documentale dove praticabile

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

- transactional rollback stack
- modello di esecuzione dry-run
- modalità output human/plain/JSON
- bundler di moduli vendorabile
- reference API generata
- shell completion per una futura CLI Bashloom

Nessun elemento successivo alla v0.1 è considerato impegnativo fino a quando non viene specificato nella documentazione e, quando opportuno, tramite ADR.
