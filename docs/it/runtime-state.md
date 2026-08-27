# API runtime state

Questo documento descrive le primitive Bashloom M4 per output, logging, environment, configurazione e stato.

> Stato: pre-v0.1. Le API pubbliche possono ancora cambiare prima della prima release utilizzabile con tag.

## Modalità di output

Imposta `BLM_OUTPUT_MODE` a uno dei seguenti valori:

- `human` — rendering predefinito orientato al terminale, con colore quando supportato;
- `plain` — testo deterministico senza colore ANSI;
- `json` — un oggetto JSON per ogni record di stato/key-value emesso.

### `blm_output_mode`
Stampa la modalità di output effettiva. I valori non validi restituiscono status `2`.

### `blm_kv <key> <value>`
Emette un record key/value usando la modalità di output attiva.

Gli helper di stato esistenti (`blm_info`, `blm_success`, `blm_warn`, `blm_error`) ora rispettano `BLM_OUTPUT_MODE`. La semantica degli stream resta invariata: info/success usano stdout, warn/error stderr.

## Logging

### `blm_log <debug|info|warn|error> <message...>`
Emette un record di log filtrato. `BLM_LOG_LEVEL` usa `info` come default e accetta `debug`, `info`, `warn` o `error`.

Quando `BLM_LOG_FILE` non è vuoto, i record accettati vengono anche aggiunti a quel file usando un formato testuale stabile con timestamp. L'output console continua invece a seguire `BLM_OUTPUT_MODE`.

Il semplice sourcing di Bashloom non apre file di log e non produce output.

## Helper environment

### `blm_env_get <NAME> [fallback]`
Stampa il valore esatto di una variabile environment valida. Se è unset, stampa il fallback opzionale. Senza fallback, una variabile unset restituisce status `1`.

### `blm_env_bool <NAME> [fallback]`
Interpreta i comuni valori booleani:

- true: `1`, `true`, `yes`, `on`;
- false: `0`, `false`, `no`, `off`.

Un testo booleano non valido restituisce status `2`. L'helper non modifica l'environment.

## Configurazione sicura

I file di configurazione Bashloom usano volutamente un formato dati minimale:

```text
# commento
APP_NAME=Bashloom
MODE=production
```

Regole:

- le righe vuote e quelle che iniziano con `#` vengono ignorate;
- tutte le altre righe devono essere `key=value`;
- le key usano lettere, numeri, `_`, `.`, `-` e devono iniziare con una lettera o `_`;
- i valori sono testo letterale;
- virgolette, `$()`, backtick, riferimenti a variabili e sintassi shell non vengono mai valutati;
- le key duplicate richieste vengono rifiutate.

### `blm_config_validate <file>`
Valida il file come dati key/value Bashloom.

### `blm_config_get <file> <key> [fallback]`
Legge un valore letterale. Una key mancante restituisce `1` salvo presenza di fallback.

### `blm_config_has <file> <key>`
Restituisce successo quando la key esiste ed è non ambigua.

Bashloom non implementa mai il caricamento config tramite `source` o `eval`.

## State file

Gli state file usano lo stesso modello dati key/value dei file di configurazione.

### `blm_state_get <file> <key> [fallback]`
Legge lo stato. Uno state file mancante si comporta come una key mancante.

### `blm_state_set <file> <key> <value>`
Crea o aggiorna una key tramite `blm_atomic_write`. I valori contenenti newline vengono rifiutati per mantenere il file strutturalmente non ambiguo.

### `blm_state_delete <file> <key>`
Rimuove una key atomicamente. La cancellazione da un file mancante termina con successo come no-op.

Le scritture dello stato preservano le altre righe valide e i commenti. Gli state file esistenti malformati vengono rifiutati invece di essere riscritti silenziosamente.

## Source safety

M4 mantiene il contratto source-safe esistente. Il sourcing di Bashloom non:

- seleziona globalmente una modalità di output;
- crea o apre un file di log;
- legge configurazioni;
- crea stato;
- modifica variabili environment;
- esegue testo fornito dal caller.
