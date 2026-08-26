# Architettura

Bashloom è progettato come runtime library modulare caricabile interamente oppure tramite moduli selezionati.

## Layer

```text
Bashloom
├── core          capability runtime/terminale e primitive condivise
├── ui            output da terminale destinato all'utente
├── ops           esecuzione, retry, wait, cleanup e helper di affidabilità
├── system        filesystem, path, permessi, XDG e helper di piattaforma
└── integrations  adapter opzionali per strumenti esterni
```

## Regole architetturali

### Core

Il core deve rimanere privo di dipendenze obbligatorie oltre a Bash. Non deve richiedere `gum`, `fzf`, `jq`, Python, Node.js o package manager specifici della piattaforma.

### Source safety

Importare Bashloom non deve abilitare silenziosamente `set -e`, `set -u`, `pipefail`, sostituire trap del chiamante o modificare `IFS`. Eventuali helper per strict mode dovranno essere API opt-in esplicite.

### Namespace pubblico

- `blm_*`: funzioni pubbliche
- `_blm_*`: funzioni interne
- `BLM_*`: variabili di configurazione pubbliche
- `_BLM_*`: stato interno

### Capability opzionali

Gli strumenti esterni possono migliorare il comportamento, ma la loro assenza non deve rompere feature core non correlate. I backend avanzati devono essere rilevati tramite capability check e degradare in modo deterministico.

### Separazione tra output ed esecuzione

Rendering UI ed esecuzione dei comandi sono responsabilità separate. Un wrapper estetico attorno a un comando deve preservarne l'exit status e non deve trasformare un fallimento in successo.

### Compatibilità

Target iniziale:

- Bash >= 4.3
- Linux: first-class
- WSL: target supportato
- macOS: best effort nelle prime release
- POSIX `sh` e BusyBox `ash`: esplicitamente fuori scope

## Caricamento dei moduli

Il modello di lungo periodo prevede:

1. caricamento della runtime completa;
2. sourcing selettivo dei moduli;
3. bundle generati/vendorabili contenenti solo i moduli richiesti.

Il bundler non fa parte della v0.1, ma la struttura dei sorgenti non deve impedirne l'introduzione futura.
